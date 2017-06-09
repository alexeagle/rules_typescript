import * as ts from 'typescript';

const factory: ts.TransformerFactory<ts.SourceFile> =
    (context: ts.TransformationContext) => {
      function transform(node: ts.SourceFile): ts.SourceFile {
        throw new Error('I RAN!');
        // return node;
      }
      return transform;
    };
const xforms: ts.CustomTransformers = {
  before: [factory]
};
export default xforms;
