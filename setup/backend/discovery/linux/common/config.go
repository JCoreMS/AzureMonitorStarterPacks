package common

// Config struct definition
// It defines the structure of the config file
type Config struct {
	// Main config section
	Main struct {
		LogPath  string
		LogLevel string
	}
	// NginxCollector section
	NginxCollector NginxCollector
	// sub-section NginxCollectorWebsite
	NginxCollectorWebsite NginxCollectorWebsite
}

// NginxCollector struct definition
type NginxCollector struct {
	LogPath string
}

// NginxCollectorWebsite struct definition
type NginxCollectorWebsite map[string]*WebSite

// WebSite struct definition
type WebSite struct {
	Url               string
	ScrapeIntervalsec int
}
