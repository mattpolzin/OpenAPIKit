Thank you for considering contributing to OpenAPIKit!

Take a look at the [Code of Conduct](https://github.com/mattpolzin/OpenAPIKit/blob/master/CODE_OF_CONDUCT.md) and note the [MIT license](https://github.com/mattpolzin/OpenAPIKit/blob/master/LICENSE.txt) associated with this project.

If you are preparing a change for the current release of OpenAPIKit (major version 3), branch off of the `main` branch of this repositroy. If you are preparing a fix for version 2 of OpenAPIKit, branch off of the `release/2_x` branch of this repository. If you are preparing a change for the next major release of OpenAPIKit (major version 4), branch off of the `release/4_0` branch of this repository.

Please do the following in the course of preparing a branch and pull request for this project.

- Create an issue motivating the changes you want to make if one does not already exist. If you are unsure of how to adress an issue, seek out converstation on the issue before committing to a strategy.
- Add test cases that cover the logical branches of your addition. For bug fixes, at least one of your test cases should fail prior to your change to serve as a regression test against the bug being fixed.
- If relevant, cite the OpenAPI specification in describing your changes.
- If your changes only apply for OpenAPI 3.1.x documents, modify the `OpenAPIKit` module. If your changes only apply for OpenAPI 3.0.x documents, modify the `OpenAPIKit30` module. If your changes apply to both, please port your changes from one to the other so both are updated if you have time. If you don't have time to apply changes to both modules, create a PR and ask for assistance with porting your changes. If you are not sure whether your changes apply to both modules, you can also create a PR and then ask for clarification.

### Goals for each currently maintained major version

`2.x`: Non-breaking changes that fix bugs for working with OpenAPI 3.0.x.
`3.x`: Non-breaking changes that fix bugs or add improvements to the support of either OpenAPI 3.0.x or OpenAPI 3.1.x.

#### Goals for the Next/unreleased version
The next major version will be `4.0`.

This release will prioritize code-rewriting and project configuration updates that modernize the Swift used in this project.

**Please create GitHub issues** to propose any specific code refactoring you would like to do as I am opinionated about the degree to which I want to refactor; in other words, I aim to adopt more modern Swift, but avoid structural changes motivated by a difference in opinion rather than common Swift coding practices.

An example of a change I would love to see (albeit an especially trivial one) is the replacement of `if let something = something` with `if let something` (i.e. code that rebinds an optional to the same name within the following conditional scope). There are other trivial syntax transformations like this that I would very much appreciate.

An example of a change I am open to but has slightly more potential for disruption would be refactoring generic code to use new `any`/`some` keywords. I would want to think through the specific suggestion and discuss in a GitHub ticket prior to seeing the Pull Request.

An example of a change I am much less likely to accept is the refactoring of two types that combines them into a new single type. Changes like this would need to be clearly motivated in a GitHub issue and even then I may disagree with the benefits of the refactor.

Thanks!
