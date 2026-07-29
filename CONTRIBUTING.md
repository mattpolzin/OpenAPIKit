Thank you for considering contributing to OpenAPIKit!

Take a look at the [Code of Conduct](https://github.com/mattpolzin/OpenAPIKit/blob/master/CODE_OF_CONDUCT.md) and note the [MIT license](https://github.com/mattpolzin/OpenAPIKit/blob/master/LICENSE.txt) associated with this project.

If you are preparing a change for the current release of OpenAPIKit (major version 6), branch off of the `main` branch of this repositroy. If you are preparing a fix for version 5 of OpenAPIKit, branch off of the `release/5_x` branch of this repository. If you are preparing a change for the next major release of OpenAPIKit (major version `7`), branch off of the `release/7_0` branch of this repository.

Please do the following in the course of preparing a branch and pull request for this project.

- Create an issue motivating the changes you want to make if one does not already exist. If you are unsure of how to adress an issue, seek out converstation on the issue before committing to a strategy.
- Add test cases that cover the logical branches of your addition. For bug fixes, at least one of your test cases should fail prior to your change to serve as a regression test against the bug being fixed.
- If relevant, cite the OpenAPI specification in describing your changes.
- If your changes only apply for OpenAPI 3.1.x and 3.2.x documents, modify the `OpenAPIKit` module. If your changes only apply for OpenAPI 3.0.x documents, modify the `OpenAPIKit30` module. If your changes apply to both, please port your changes from one to the other so both are updated if you have time. If you don't have time to apply changes to both modules, create a PR and ask for assistance with porting your changes. If you are not sure whether your changes apply to both modules, you can also create a PR and then ask for clarification.
- If your changes only apply to OpenAPI 3.2.x documents, add "conditional warnings" so that the `OpenAPIKit` module can support the OAS 3.2.x feature but also warn if an OAS 3.1.x document uses that feature. See existing types with `HasConditionalWarnings` protocol conformance for examples.

### AI Contribution Policy
This project accepts AI-assisted contributions but requests contributors to fully own PRs and Issues that are submitted for review. This project is maintained with very limited availability on an entirely voluntary basis so please:
  - Write your issues and PR descriptions by hand or at least take any particularly verbose AI text and boil it down to exactly what you need to share with other OpenAPIKit contributors and maintainers.
  - Fully understand all code you submit to the project so that you can answer questions or explain decisions to maintainers who are reviewing your code.
  - Do not respond to PR feedback by feeding the maintainer's comments into AI and then pasting the AI's response. Once you submit something to OpenAPIKit as a contribution, we expect communication to be human-to-human. If the goal was to collaborate directly with AI, maintainers could feed their comments into that AI themselves. The goal of feedback/conversation is to come to a shared understanding of the best outcome through context sharing and reasoned debate and a predicive text model is not capable of reasoning so it is not suitable.

The following are some more specific requests around PR descriptions. Really these apply to both AI and non-AI contributions, but AI is pretty well known for the following kinds of things:
  - Do not write down what files you made changes to or enumerate the changes you made. Commit messages should enumerate the changes and git already tracks what files you changed. The PR description should be a high level description and explanation of motivation for various decisions made.
  - Do not write down what testing was performed. All PRs should pass the full CI test suite in GitHub, maintainers don't need to know what tests are passing for you locally. Running the tests locally is just as a decision point for whether the PR is ready to put up for review.

### Goals for each currently maintained major version

`5.x`: Non-breaking changes that fix bugs or add improvements to the support of OpenAPI Spec v3.0.x, OpenAPI Spec v3.1.x, or OpenAPI Spec v3.2.x.

`6.x`: Breaking changes that fix bugs or Non-breaking changes that add improvements to the support of OpenAPI Spec v3.0.x, OpenAPI Spec v3.1.x, or OpenAPI Spec v3.2.x.

#### Goals for the Next/unreleased version
The next major version will be `7.0`.

The big goal of the `v7.0` release is removing OpenAPI 3.0 Standard tooling. That is specifically _not_ removing the ability to encoding/decode OAS 3.0 documents or convert OAS 3.0 documents to OAS 3.1/3,2 documents, but any other tooling related specifically to OAS 3.0 documents should get removed. This will reduce maintenance burden going forward. In effect this means that users who want to perform simplification, validation, etc. on OAS 3.0 documents will need to convert them (in Swift, using the OpenAPIKitCompat module provided by OpenAPIKit) to OAS 3.1/3.2 documents and then run the simplification, validation, etc. on those converted documents.

**Please create GitHub issues** to propose any specific code refactoring or breaking changes you would like to see as I am opinionated about the degree to which I want to refactor and breaking changes should be well motivated; in other words, I aim to adopt more modern Swift, but avoid structural changes motivated by a difference in opinion rather than common Swift coding practices.

An example of a change I am open to but has slightly more potential for disruption would be refactoring generic code to use new `any`/`some` keywords. I would want to think through the specific suggestion and discuss in a GitHub ticket prior to seeing the Pull Request.

An example of a change I am much less likely to accept is the refactoring of two types that combines them into a new single type. Changes like this would need to be clearly motivated in a GitHub issue and even then I may disagree with the benefits of the refactor.

Thanks!
