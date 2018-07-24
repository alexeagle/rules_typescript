package workspace

import (
	"fmt"
	"os"
	"path/filepath"
)

// Root finds the closest directory containing a WORKSPACE file from p.
func Root(p string) (string, error) {
	p, err := filepath.Abs(p)
	if err != nil {
		return "", fmt.Errorf("unable to determine workspace root from %s: %v", p, err)
	}

	for root := filepath.Dir(p); root != "." && root != "/"; root = filepath.Dir(root) {
		if _, err := os.Stat(filepath.Join(root, "WORKSPACE")); err != nil {
			if os.IsNotExist(err) {
				// WORKSPACE was not found in this directory, keep looking.
				continue
			}
			// The error was something more serious than a "not exists" error.
			return "", err
		}
		return root, nil
	}
	return "", fmt.Errorf("unable to determine workspace root")
}
