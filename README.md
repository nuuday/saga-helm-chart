# Saga Helm Chart

This repository contains the helm templates that are used to deploy saga services to the Nuuday managed-aks kubernetes cluster.

It uses github pages, see deployments here : https://nuuday.github.io/saga-helm-chart/index.yaml 

For more documentation on how the managed-aks cluster is configured, see [this documentation](https://github.com/nuuday/managed-eks/blob/main/docs/tenant/tenant-guide.md#managed-eksaks-tenant-guide).

## Releasing new versions

An a Github Action will automatically release a new version of the chart when ```version```  in ```charts/app/Chart.yaml``` is changed. It uses semantic versioning. See also [the official documentation](https://helm.sh/docs/chart_best_practices/dependencies/#versions) for more details.

## Ingress

For documentation on how to configure ingress resources that use the ```nginx-controller``` see the [official documentation](https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/).

### Rewrite example

Mapping a path to a different path on a service. Eg. mapping ```/someEndpoint``` to ```/some/internal/path/to/someEndpoint``` internally.
```yaml
app:
  ingress:
    ingresses:
      - name: external-ingress
        className: nginx
        annotations:
              nginx.ingress.kubernetes.io/use-regex: "true"
              nginx.ingress.kubernetes.io/rewrite-target: /some/internal/path/to/someEndpoint$1$2
        hosts:
          - host: external-host-dev
            paths:
              - path: /someEndpoint(/|$)(.*)
                pathType: Prefix
        tls:
          - secretName: aks-nuuday-nmp-external-dev-tls
            hosts:
              - external-host-dev
```
See also [this example](https://kubernetes.github.io/ingress-nginx/examples/rewrite/#rewrite).

### Ingresses

Two ```ingress-nginx``` ingress are configured on the aks cluster, more details can also be found in [this documentation](https://github.com/nuuday/managed-eks/blob/main/docs/tenant/tenant-guide.md#ingresses).

**Internal ingress:**  
Exposes services internally on Nuuday networks. To use this, use set ingress class name to ```nginx-internal``` on ingress resources.

**External ingress**  
Exposes services externally to the public internet. This is the default ingress-class applied to ingress objects. Can also be specified explicitly using the ```nginx``` ingress class name.


## Developing charts and chart templates

https://helm.sh/docs/

There are different approaches to developing and verifying helm charts and templates.

### Debugging helm templates 

Both when consuming and developing chart tempaltes in this repository, it may be useful to point helm to a local version of the template it consumes instead of a released template version.

This makes it possible to test how changes to values provided to the chart affects the rendered or released chart. And makes it possible to quickly test how changes to chart templates affect the rendered chart.

Aside from this repository you will need to clone a repository that contains a Helm Chart configuration that consumes this template. One example may be https://github.com/nuuday/saga-product-service.

In the ```.helm``` directory of the above service edit ```Chart.yaml``` as shown below.
```diff
apiVersion: v2
name: saga-product-service
description: A Helm chart for Kubernetes
type: application
version: 1.0.3
appVersion: "1.0.0"

dependencies:
  alias: app
  name: app
  version: "3.0.0"
- repository: "https://nuuday.github.io/saga-helm-chart"
+ repository: "file:///path/to/saga-helm-chart/charts/app"
```
This makes it so running ```helm dependency update``` in the ```.helm``` directory of ```saga-product-service``` will package the local chart template containing whatever changes you may have made to the template, and install it to the product service.

One possible template development flow could be. 

1. Make changes to chart template
2. Run ```helm dependency update```
3. Verify changes using one or more of the below mentioned commands
4. Repeat

### ```helm template```

You can render the a chart using a set of provided value files. Using the [```helm template```](https://helm.sh/docs/helm/helm_template/) command. This is useful if you wish to verify that the resources look right, and that the chart _can_ render. This only guarentees that the chart can render using provided values, not that its output is actually correct when deployed to k8s.

When run from a directory containing a valid Chart.yaml the following command would merge the provided values files and attempt to render a Chart.yaml.
```shell
helm template . -f ./values.yaml -f ./.../development.values.yaml
```

### ```helm upgrade```

The [helm upgrade](https://helm.sh/docs/helm/helm_upgrade/) command installs or upgrade the release of a chart to a k8s cluster. This command is useful when you have reached a point where you're reasonably sure that the rendered you are working on is correct, and want to verify that it is actually valid.

The following command will render a chart in the current terminal context but not actually deploy it, as it uses the ```--dry-run``` flag. This differs from ```helm template``` as helm takes the state of the k8s cluster into account when deploying.
```shell
helm upgrade --install  saga-product-service  . \
	-f ./environments/development.values.yaml -f ./values.yaml \
	--set app.image.tag=IMAGE TAG \
	--set app.env.ASPNETCORE_ENVIRONMENT=Development \
	-n saga-nmp-dev --dry-run
```

Omitting the ```--dry-run``` flag will cause the command to deploy the provided chart to k8s. This should usually _only_ be done manually in the non-prod environment, which is specified by the ```-n saga-nmp-dev``` argument. This is useful when you want to actually veryfiy that the chart deploys, and that it functions as expected.
```shell
helm upgrade --install  saga-product-service  . \
	-f ./environments/development.values.yaml -f ./values.yaml \
	--set app.image.tag=IMAGE TAG \
	--set app.env.ASPNETCORE_ENVIRONMENT=Development \
	-n saga-nmp-dev
```
