package common

import (
	"io"
	"net/http"

	logger "github.com/Welasco/AzureMonitorStarterPacksCollector/common/logger"
)

// Http_client function
// This function is used to make HTTP requests to NGINX
// It returns the body of the response as string, the response itself and an error
func Http_client(url string) (string, *http.Response, error) {
	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		logger.Error("Fail to create HTTP request to NGINX")
		logger.Error(err)
		return "", &http.Response{}, err
	}

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		return "", &http.Response{}, err
	}

	defer resp.Body.Close()

	body, _ := io.ReadAll(resp.Body)
	bodystr := string(body)
	logger.Debug("HTTP Boddy of URL", url, ":\n", bodystr)

	return bodystr, resp, err

}
