package updater

import "fmt"

// infof is an API shim.
func infof(format string, args ...interface{}) {
	fmt.Printf(format+"\n", args...)
}
