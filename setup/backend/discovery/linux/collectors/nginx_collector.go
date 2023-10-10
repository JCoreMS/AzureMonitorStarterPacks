package collectors

import (
	"encoding/csv"
	"os"
	"regexp"
	"sync"
	"time"

	"github.com/Welasco/AzureMonitorStarterPacksCollector/common"
	logger "github.com/Welasco/AzureMonitorStarterPacksCollector/common/logger"
)

// Nginx_log struct definition for the csv file
type nginx_properties struct {
	active_connections string
	server_accepts     string
	server_handled     string
	server_requests    string
	reading            string
	writing            string
	waiting            string
}

// Implementing the interface LogCollector CollectLog function
// CollectLog receives a telemetry information from NGINX module and processes it.
func (nlog *Nginx_log) CollectLog(bodystr string) error {

	// Regular expression patterns
	activeConnPattern := regexp.MustCompile(`Active connections: (\d+)`)
	serviceConnPattern := regexp.MustCompile(` (\d+) (\d+) (\d+)`)
	rwwPattern := regexp.MustCompile(`Reading: (\d+) Writing: (\d+) Waiting: (\d+)`)

	// Find matches in the text
	activeConnMatches := activeConnPattern.FindStringSubmatch(bodystr)
	serviceConnMatches := serviceConnPattern.FindStringSubmatch(bodystr)
	rwwMatches := rwwPattern.FindStringSubmatch(bodystr)

	// popupate the struct Nginx_log
	nginx_properties := nginx_properties{
		active_connections: activeConnMatches[1],
		server_accepts:     serviceConnMatches[1],
		server_handled:     serviceConnMatches[2],
		server_requests:    serviceConnMatches[3],
		reading:            rwwMatches[1],
		writing:            rwwMatches[2],
		waiting:            rwwMatches[3],
	}

	// write to csv file
	nlog.write_to_csv(&nginx_properties)

	return nil
}

// write_to_csv file function
// It writes the telemetry information from NGINX module to a csv file
func (nlog *Nginx_log) write_to_csv(nginx_log *nginx_properties) {
	file, err := os.OpenFile(nlog.LogPath, os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
	if err != nil {
		logger.Error("Unable to open file", nlog.LogPath)
		logger.Error(err)
		logger.Error("Stopping NGINX collector for now...")
		nlog.Stop()
	}

	defer file.Close()
	writer := csv.NewWriter(file)
	defer writer.Flush()
	//writer.Write([]string{"Active_connections", "Server_accepts", "Server_handled", "Server_requests", "Reading", "Writing", "Waiting"})
	writer.Write([]string{time.Now().Format("2006-01-02T15:04:05"), nlog.SiteName, nginx_log.active_connections, nginx_log.server_accepts, nginx_log.server_handled, nginx_log.server_requests, nginx_log.reading, nginx_log.writing, nginx_log.waiting})
}

// Variable to control the status of the collector
// Running or Stopped
var shouldStop bool

// Implementing the interface LogCollector Start function
// It initialize the main loop to collect the telemetry information from NGINX module
func (nlog *Nginx_log) Start(wg *sync.WaitGroup) error {
	logger.Info("START - Starting NGINX ", nlog.SiteName, " collector...", nlog.Url)
	shouldStop = false
	for !shouldStop {
		respbody, resp, err := common.Http_client(nlog.Url)
		if err != nil {
			logger.Error("Failed to connect to NGINX", nlog.Url)
			logger.Error(err)
			logger.Error("Stopping NGINX collector for now...")
			nlog.Stop()
			return err
		}
		if resp.StatusCode != 200 {
			logger.Error("Failed to connect to NGINX", nlog.Url)
			logger.Error("Status code:", resp.StatusCode)
			logger.Error("Stopping NGINX collector for now...")
			nlog.Stop()
			return err
		}
		nlog.CollectLog(respbody)
		time.Sleep(time.Duration(nlog.ScrapeIntervalsec) * time.Second)
	}

	wg.Done()
	return nil
}

// Implementing the interface LogCollector Stop function
// It should gracefully shut down the collector.
func (nlog *Nginx_log) Stop() error {
	logger.Info("STOP - Stopping NGINX collector...", nlog.SiteName)
	shouldStop = true
	return nil
}

// Implementing the interface LogCollector GetStatus function
// This can be used to check if the collector is running or stopped.
func (nlog *Nginx_log) GetStatus() string {
	if !shouldStop {
		return "Running"
	} else if shouldStop {
		return "Stopped"
	}
	return "Unknown"
}

// Constructor for Nginx Collector function
// It returns a pointer to the Nginx_log struct with all the methods implementation of the interface LogCollector
func Newnginx_log(siteName string, cfg *common.WebSite, logPath string) *Nginx_log {
	var nlog Nginx_log = Nginx_log{
		SiteName:          siteName,
		LogPath:           logPath,
		Url:               cfg.Url,
		ScrapeIntervalsec: cfg.ScrapeIntervalsec,
	}
	return &nlog
}
