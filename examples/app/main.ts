import * as ng from 'angular';
import {helloWorldComponent} from './hello-world/hello-world';

ng.module('HelloWorldApp', []).component('helloWorld', helloWorldComponent);

ng.element(() => {
  ng.bootstrap(document, ['HelloWorldApp']);
});
