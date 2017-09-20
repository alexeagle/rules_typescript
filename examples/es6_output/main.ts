import {Greeter} from './greeter';

for (let i = 0; i < 100; i++) {
  console.log(new Greeter(i).greet(i));
}
