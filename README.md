<p align="center"><img src="help/logo/logo_official.png"></p>

# ["What is kubeojo?" in 10 seconds](help/README.md)

# Developing kubeojo

See [devel-setup](kubeojo/README.md)

# How to run kubeojo

At this point kubeojo is under active development and has not yet reached version 1.0. As soon as a stable version is ready, the docs will be updated to describe how to run kubeojo.
( Please feel free to pick up issues from GitHub if you want to contribute for version 1.0) 

# What is kubeojo?

Nowadays, it is extremely common that projects have a test suite running on CI system to ensure the project's stability.

When test suites get big, it is very often the case that there are "brittle tests" in the suite. These are the kinds of tests that typically run just fine, but randomly fail from time to time (such as once every 10 runs or so).

Kubeojo methodically examines your tests failures. It stores the results and visualizes the "brittle tests" to help detect and fix them. The UI of kubeojo is powered by Phoenix 1.3 and D3.js.


# Configuration:

In order to use kubeojo, you need to have 2 YAML files configured:

1) Jenkins credentials:
`kubeojo/kubeojo/config/jenkins_credentials.yml`

as password you can use the a Jenkins Token:
```yaml
jenkins_url: "https://i_love_opensuse.ci.com/"
username: "Jenkins_username"
password: "2faidfakjfdkjadf30ff"
```

2) Jenkins Jobs you want to analyze:

`kubeojo/kubeojo/config/jenkins_jobs.yml`

Here you should insert the name of the jobs you want to analyze the tests results for.

**Important**: your jobs need to export tests in **junit-format** to ensure kubeojo can fetch the junit_results.

```ỳaml
jenkins_jobs: ["manager-3.1-cucumber", "manager-Head-cucumber"]
```

## Roadmap:

https://github.com/MalloZup/kubeojo/issues

# Contributors:

Thanks to all [contributors](https://github.com/MalloZup/kubeojo/graphs/contributors) for kubeojo! 


<p align="center"><img src="help/logo/logo_small_official.png"></p>
