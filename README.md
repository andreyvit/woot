# Woot! — Instant project creation

[![Greenkeeper badge](https://badges.greenkeeper.io/andreyvit/woot.svg)](https://greenkeeper.io/)

Create a template once, use everywhere:

    $ woot npm-package foo-bar

    You will now be prompted for the following values:

      --description VALUE

    You can also provide them on the command line if you want.

    description: Amazing new package

    Argument values:
      name (underscored) = foo_bar
      name (dashed) = foo-bar
      name (camelCase) = fooBar
      name (CamelCase) = FooBar
      description (human readable) = Amazing new package
      github_user (raw) = andreyvit


    Is this correct (yes/no) [yes]:

     create    /private/tmp/wutest/foo-bar
     add       .npmignore
     add       .gitignore
     add       package.json
     add       README.md
     add       lib/index.coffee
     add       lib/index.js
     add       test/foo_bar_test.coffee
     add       test/foo_bar_test.js
     run       git init
     run       npm install

    Finished.

The second argument defaults to the current folder. Woot never overwrites files, so if you run it again, it will only add the missing ones.

Any subfolder under `~/.woot` is a template. In the future, I might add an option to distribute templates as npm modules (woot-something).

Variables like `__something__` are substituted in file names and data. `__name__` is set to the folder name, other values come from `~/.woot.json`, command-line arguments or interactive answers.

You can save variables to `~/.woot.json` using `--save`:

    woot --github-user andreyvit --save

Add `woot.json` to your template to run some custom commands as the last step:

    {
        "after": [
            "git init",
            "npm install"
        ]
    }


## Variable substitution details

Variables are automatically transformed by example. If you provide `CoolModel` as a value for model_name, the following substitutions will be made:

    __model_name_raw__   CoolModel   # untransformed input
    __model_name__       cool_model
    __ModelName__        CoolModel
    __modelName__        coolModel
    __model-name__       cool-model

You can append `woot` to any name, which is both cool and helps to provide examples for single-word names:

    __name__             foo_bar
    __name_woot__        foo_bar
    __name-woot__        foo-bar
    __NameWoot__         FooBar
    __nameWoot__         fooBar
    __name woot__        foo bar
    __Name Woot__        Foo Bar

Note that the last two ones (with spaces) are only available via woot (to avoid runaway name lookups). The corresponding substitutions for model_name variable will be:

    __model_name woot__  cool model
    __Model_Name Woot__  Cool Model

Woot!


## Installation

    npm install woot


## License

© 2012, Andrey Tarantsov, distributed under the MIT license.


## Make woot, not wat!
