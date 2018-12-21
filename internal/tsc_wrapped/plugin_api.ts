/**
 * @license
 * Copyright 2017 The Bazel Authors. All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 *
 * You may obtain a copy of the License at
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/**
 * @fileoverview
 * Provides APIs for extending TypeScript.
 * Based on the LanguageService plugin API in TS 2.3
 */

import * as ts from 'typescript';

/**
 * This API is simpler than LanguageService plugins.
 * It's used for plugins that only target the command-line and never run in an
 * editor context.
 */
export interface TscPlugin {
  /**
   * Allow plugins to add additional files to the program.
   * For example, tsickle adds a lib_name.externs.js output
   * and Angular creates ngsummary and ngfactory files.
   * @param rootFiles the files that were part of the original program
   */
  generatedFiles?(rootFiles: string[]): {
    [fileName: string]: (host: ts.CompilerHost) => {fileName: string, content: string}|undefined
  };

  /**
   * Same API as ts.LanguageService: allow the plugin to contribute additional
   * diagnostics
   * IMPORTANT: plugins must propagate the diagnostics from the original program.
   * Execution of plugins is not additive; only the result from the top-most
   * wrapped Program is used.
   */
  wrap(p: ts.Program, config?: {}, host?: ts.CompilerHost): ts.Program;

  /**
   * Allow plugins to contribute additional TypeScript CustomTransformers.
   * These can modify the TS AST, JS AST, or .d.ts output AST.
   *
   * @param fileNameToModuleName a helper the transformer can use when generating new import statements
   */
  createTransformers?(fileNameToModuleName: (s: string) => string): ts.CustomTransformers;
}

// TODO(alexeagle): this should be unioned with tsserverlibrary.PluginModule
export type Plugin = TscPlugin;

/**
 * The proxy design pattern, allowing us to customize behavior of the delegate
 * object.
 * This creates a property-by-property copy of the object, so it can be mutated
 * without affecting other users of the original object.
 * See https://en.wikipedia.org/wiki/Proxy_pattern
 */
export function createProxy<T>(delegate: T): T {
  const proxy = Object.create(null);
  for (const k of Object.keys(delegate)) {
    proxy[k] = function() {
      return (delegate as any)[k].apply(delegate, arguments);
    };
  }
  return proxy;
}
