
# monads


[![CircleCI](https://circleci.com/gh/yourgithubhandle/monads/tree/master.svg?style=svg)](https://circleci.com/gh/yourgithubhandle/monads/tree/master)


**Contains the following libraries and executables:**

```
monads@0.0.0
│
├─test/
│   name:    TestMonads.exe
│   require: monads/library
│
├─library/
│   library name: monads/library
│   require:
│
└─executable/
    name:    MonadsApp.exe
    require: monads/library
```

## Developing:

```
npm install -g esy
git clone <this-repo>
esy install
esy build
```

## Running Binary:

After building the project, you can run the main binary that is produced.

```
esy x MonadsApp.exe 
```

## Running Tests:

```
# Runs the "test" command in `package.json`.
esy test
```
