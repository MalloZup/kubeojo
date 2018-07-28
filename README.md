<p align="center"><img src="help/logo/logo_official.png"></p>

# [what is kubeojo in 10sec](help/README.md)

# Developing kubeojo:

[devel-setup](kubeojo/README.md)

# How to run kubeojo

At this point kubeojo is under the dev. phase not 1.0 version, as soon a version is ready i will update the doc for running kubeojo.
( you can still pick up issues from GitHub if you want to contribute for 1.0 version) 

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
jenkins_url: "https://i_love_opensuse.ci.com/"
username: "Jenkins_username"
password: "2faidfakjfdkjadf30ff"
```

2) Jenkins Jobs you want to analyze.

`kubeojo/kubeojo/config/jenkins_jobs.yml`

Insert here the jobs name you want to analyze the tests-results.

**Important**: your jobs need to export tests in **junit-format**, so that kubeojo can fetch the junit_results.

```ỳaml
jenkins_jobs: ["manager-3.1-cucumber", "manager-Head-cucumber"]
```

## Roadmap:

https://github.com/MalloZup/kubeojo/issues

# Contributors:

Thanks to all [contributors](https://github.com/MalloZup/kubeojo/graphs/contributors) for kubeojo! 

# Releasing:
(relasing)[help/relasing.md]


<p align="center"><img src="help/logo/logo_small_official.png"></p>
