# kubeojo

# [What is kubeojo in 10 seconds](/help/README.md)

# What is kubeojo?

Each project nowdays have a testsuite that is running on CI for ensure it stability.

When having big testsuites, there are always "brittle tests", tests that fail like 1 time on 10 Runs.

Kubeojo examine methodically and in detail your tests failures:
storing the results and  visualizing the "brittle tests" help to detect this tests and fix them.

Kubeojo will track and visualize this tests with phoenix and D3.js.



# Configuration:

In order to use kubeojo, you need to have 2 yaml files configured.

1) Jenkins credentials.
`kubeojo/kubeojo/config/jenkins_credentials.yml`

as password you can use the a Jenkins Token.
```yaml
jenkins_url: "https://4ci.suse.de/"
username: "Jenkins_username"
password: "2faidfakjfdkjadf30ff"
```

2) Jenkins Jobs you want to analyze.

Insert here the jobs name you want to analyze the tests-results.

**Important**: your jobs need to export tests in **junit-format**, so that kubeojo can fetch the junit_results.

```ỳaml
jenkins_jobs: ["manager-3.1-cucumber", "manager-Head-cucumber"]
```

`kubeojo/kubeojo/config/jenkins_jobs.yml`

### Contributors:

Thanks to all [contributors](https://github.com/MalloZup/kubeojo/graphs/contributors) for kubeojo! 

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

Feel free to take a look on issues  (which are filtered for getting started).
