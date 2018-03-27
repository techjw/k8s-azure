cluster:
  name: azurek8s
  version: v1.9.2
  disable_package_installation: false
  disconnected_installation: false

  networking:
    pod_cidr_block: 172.16.0.0/16
    service_cidr_block: 172.20.0.0/16
    update_hosts_files: true
    http_proxy: ""
    https_proxy: ""
    no_proxy: ""

  certificates:
    expiry: 17520h
    ca_expiry: 17520h

  ssh:
    user: ${adminuser}
    ssh_key: /home/${adminuser}/cluster.pem
    ssh_port: 22

  kube_apiserver:
    option_overrides: {}
  kube_controller_manager:
    option_overrides: {}
  kube_scheduler:
    option_overrides: {}
  kube_proxy:
    option_overrides: {}
  kubelet:
    option_overrides:
      max-pods: 50
      kube-reserved: "cpu=500m,memory=500Mi"
      system-reserved: "cpu=500m,memory=500Mi"


  cloud_provider:

    # Options: aws|azure|cloudstack|fake|gce|mesos|openstack|ovirt|photon|rackspace|vsphere
    # Leave config empty if provider does not require a path to a config file.
    provider: "azure"
    config: "/home/${adminuser}/azure-cloud-provider.conf"

docker:
  disable: false
  logs:
    driver: json-file
    opts:
      max-file: "1"
      max-size: 50m
  storage:
    driver: ""
    opts: {}
    direct_lvm_block_device:
      path: ""
      thinpool_percent: "95"
      thinpool_metapercent: "1"
      thinpool_autoextend_threshold: "80"
      thinpool_autoextend_percent: "20"

docker_registry:
  server: ""
  CA: ""
  username: ""
  password: ""

add_ons:
  cni:
    disable: false
    # Options: calico|weave|contiv|custom
    provider: weave

  dns:
    disable: false
    provider: kubedns

  heapster:
    disable: true
    options:
      heapster:
        replicas: 2
        service_type: ClusterIP
        sink: influxdb:http://heapster-influxdb.kube-system.svc:8086
      influxdb:
        pvc_name: ""

  metrics_server:
    disable: true

  dashboard:
    disable: false

  package_manager:
    disable: false
    provider: helm
    options:
      helm:
        namespace: kube-system

  rescheduler:
    disable: true

etcd:
  expected_count: 1
  nodes:
  - host: "k8smaster"
    ip: "${master_ip}"
    internalip: "${master_ip}"

master:
  expected_count: 1
  load_balanced_fqdn: "${master_ip}"
  load_balanced_short_name: "${master_ip}"
  nodes:
  - host: "k8smaster"
    ip: "${master_ip}"
    internalip: "${master_ip}"
    labels:
      component: "master"

worker:
  expected_count: 2
  nodes:
  - host: "k8sworker1"
    ip: "${node1_ip}"
    internalip: "${node1_ip}"
    labels:
      component: "worker"

  - host: "k8sworker2"
    ip: "${node2_ip}"
    internalip: "${node2_ip}"
    labels:
      component: "worker"

ingress:
  expected_count: 1
  nodes:
  - host: "k8sworker1"
    ip: "${node1_ip}"
    internalip: "${node1_ip}"
    labels:
      component: "ingress"

storage:
  expected_count: 0
  nodes: []

nfs:
  nfs_volume: []
