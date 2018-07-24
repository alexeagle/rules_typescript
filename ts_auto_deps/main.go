package main

import (
	"context"
	"flag"
	"fmt"
	"os"
	"path/filepath"
	"sort"


	"github.com/bazelbuild/rules_typescript/ts_auto_deps/updater"
)

var (
	isRoot = flag.Bool("root", false, "the given path is the root of a TypeScript project "+
		"(generates ts_config and ts_development_sources targets).")
	recursive                = flag.Bool("recursive", false, "recursively update all packages under the given root.")
	removeUnusedDeclarations = flag.Bool("remove_unused_declarations", false, "remove unused dependencies on ts_declaration() targets")
	files                    = flag.Bool("files", false, "treats arguments as file names. Filters .ts files, then runs on their dirnames.")
	updateComments           = flag.Bool("update_comments", false, "Also updates taze comments after module imports based on the global index.")
)

func usage() {
	fmt.Fprintf(os.Stderr, `taze: generate BUILD rules for TypeScript sources.

usage: %s [flags] [path...]

taze generates and updates BUILD rules for each of the given package paths.
Paths are expected to reside underneath google3. If none is given, taze runs on
the current working directory.

For each of the given package paths, taze finds all TypeScript sources in the
package and adds sources that are not currently built to the appropriate
BUILD rule (ts_library or ts_declaration).

If there is no matching BUILD rule, or no BUILD file, taze will create either.

taze also updates BUILD rule dependencies ('deps') based on the source imports.

See go/typescript/taze for more documentation.

Flags:
`, os.Args[0])
	flag.PrintDefaults()
}

func main() {
	flag.Usage = usage
	flag.Parse()

	paths := flag.Args()
	if len(paths) == 0 {
		wd, err := os.Getwd()
		if err != nil {
			fmt.Fprintf(os.Stderr, "Failed to get working directory: %v\n", err)
			os.Exit(1)
		}
		paths = []string{wd}
	}

	if len(paths) > 1 && *isRoot {
		fmt.Fprintf(os.Stderr, "Can only take exactly one path with -root.\n")
		os.Exit(1)
	}

	if *files {
		paths = updater.FilterPaths(paths)
		if len(paths) == 0 {
			fmt.Fprintf(os.Stderr, "WARNING: found no TypeScript files in %s\n", paths)
			os.Exit(0)
		}
	}

	if err := updater.ResolvePackages(paths); err != nil {
		fmt.Fprintf(os.Stderr, "Failed to resolve packages: %s\n", err)
		os.Exit(1)
	}

	if *recursive {
		var allPaths []string
		for _, p := range paths {
			err := filepath.Walk(p, func(path string, info os.FileInfo, err error) error {
				if err == nil && info.IsDir() {
					allPaths = append(allPaths, path)
				}
				return err
			})
			if err != nil {
				fmt.Fprintf(os.Stderr, "taze -recursive failed: %s.\n", err)
				os.Exit(1)
			}
		}
		sort.Sort(byLengthInverted(allPaths))
		paths = allPaths
	}

	analyzer := updater.QueryBasedBlazeAnalyze
	ctx := context.Background()
	host := updater.New(*removeUnusedDeclarations, *updateComments, analyzer, updater.LocalUpdateFile)
	for i, p := range paths {
		isLastAndRoot := *isRoot && i == len(paths)-1
		changed, err := host.UpdateBUILD(ctx, p, isLastAndRoot)
		if err != nil {
			if *recursive {
				fmt.Fprintf(os.Stderr, "taze failed on %s/BUILD: %s\n", p, err)
			} else {
				fmt.Fprintf(os.Stderr, "taze failed: %s\n", err)
			}
			os.Exit(1)
		}
		if changed {
			if filepath.Base(p) == "BUILD" {
				fmt.Printf("Wrote %s\n", p)
			} else {
				fmt.Printf("Wrote %s\n", filepath.Join(p, "BUILD"))
			}
		}
	}
}

type byLengthInverted []string

func (s byLengthInverted) Len() int           { return len(s) }
func (s byLengthInverted) Swap(i, j int)      { s[i], s[j] = s[j], s[i] }
func (s byLengthInverted) Less(i, j int) bool { return len(s[i]) > len(s[j]) }
