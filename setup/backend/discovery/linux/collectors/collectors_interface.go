package collectors

import "sync"

// LogCollector defines the methods that a log collector should implement.
type LogCollector interface {
	// Start starts the log collection process.
	// It should initialize any necessary resources and prepare to receive log data.
	Start(wg *sync.WaitGroup) error

	// Stop stops the log collection process and releases any allocated resources.
	// It should gracefully shut down the collector.
	Stop() error

	// CollectLog receives a log message and processes it.
	// It should take the log message as input, apply any necessary transformations,
	// and store or forward the log data to a destination.
	CollectLog(logMessage string) error

	// GetStatus returns the current status of the log collector.
	// This can be used to check if the collector is running or stopped.
	GetStatus() string
}
