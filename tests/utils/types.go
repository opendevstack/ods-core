package utils

type EnvPair struct {
	Name  string `json:"name"`
	Value string `json:"value"`
}

type RequestBuild struct {
	Branch     string    `json:"branch"`
	Repository string    `json:"repository"`
	Env        []EnvPair `json:"env"`
	Project    string    `json:"project"`
}
type RoleBinding struct {
	SubjectName string
	SubjectType string
	Namespace   string
	RoleName    string
}

type ImageTag struct {
	Name string
	Tag  string
}

type Resources struct {
	Namespace                string
	ImageTags                []ImageTag
	BuildConfigs             []string
	DeploymentConfigs        []string
	Deployments              []string
	StatefulSets             []string
	DaemonSets               []string
	ReplicaSets              []string
	Services                 []string
	ImageStreams             []string
	Routes                   []string
	Ingresses                []string
	ConfigMaps               []string
	Secrets                  []string
	PersistentVolumeClaims   []string
	ServiceAccounts          []string
	Roles                    []string
	RoleBindings             []string
	NetworkPolicies          []string
	Jobs                     []string
	CronJobs                 []string
	Pods                     []string
	HorizontalPodAutoscalers []string
}
