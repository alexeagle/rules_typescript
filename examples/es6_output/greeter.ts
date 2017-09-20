export class Greeter {
    constructor(i: number){
      this.i = i;
    }
    private greeting = `hello, $i, world`;
    public i = 0;
    greet(i: number) {
        return this.greeting + i;
    }
}
