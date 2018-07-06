# kubeojo

# What is kubeojo?

Each project nowdays have a testsuite that is running on CI for ensure it stability.

When having big testsuites, there are always "brittle tests", tests that fail like 1 time on 10 Runs.

Storing the results and having graphs for visualizing the "brittle tests" can help to detect this tests and fix them.

Kubeojo will track and visualize this tests with phoenix and D3.js.


## Roadmap:

### Version 1:

- store jenkins junits results in database
- visulilze results with D3.js: https://bl.ocks.org/mbostock/7607535.
- deploy the app via container

### Version 2:

- be able to store other format of tests. (define format)
- ...


## How to contribute:

At moment the project is in a beta stage ( not much inside), but you can discuss the roadmap and feel free to add ideas about which graphs we could use.

Also any kind of idea/contribution is welcome, feel free to open issue for any kind of discussion related.
