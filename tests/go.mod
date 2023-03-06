module github.com/opendevstack/ods-core/tests

go 1.13

require (
	github.com/ghodss/yaml v1.0.0
	github.com/google/go-cmp v0.5.1
	github.com/imdario/mergo v0.3.8 // indirect
	github.com/jstemmer/go-junit-report v0.9.1
	github.com/kr/pretty v0.2.1 // indirect
	github.com/openshift/api v0.0.0-20180801171038-322a19404e37
	github.com/openshift/client-go v3.9.0+incompatible
	golang.org/x/net v0.0.0-20220524220425-1d687d428aca // indirect
	golang.org/x/sys v0.0.0-20220520151302-bc2c85ada10a // indirect
	gopkg.in/check.v1 v1.0.0-20190902080502-41f04d3bba15 // indirect
	k8s.io/api v0.20.0-alpha.2
	k8s.io/apimachinery v0.20.0-alpha.2
	k8s.io/client-go v0.20.0-alpha.2
)

replace github.com/googleapis/gnostic => github.com/google/gnostic v0.4.0
