#### Kube-VIP Installation

1. **Install Kube-VIP**:
   - First, you need to install Kube-VIP. You can do this by downloading the Kube-VIP binary or using a container image.
   - For example, you can download the Kube-VIP binary from the [Kube-VIP releases page](https://github.com/kube-vip/kube-vip/releases).

1. **Create a Kube-VIP Manifest**:
   - You need to create a manifest file for Kube-VIP. This manifest will define the configuration for Kube-VIP, including the virtual IP address.

   Here is a basic example of what the manifest might look like:

   ```yaml
   apiVersion: v1
   kind: ConfigMap
   metadata:
     name: kubevip
     namespace: kube-system
   data:
     vip.yaml: |
       vip: 192.168.0.100
       interface: eth0
       services:
       - name: "Control Plane"
         port: 6443
         type: LoadBalancer
   ```

   Adjust the `vip` and `interface` values to match your network configuration.

1. **Apply the Manifest**:
   - Apply the manifest to your K3s cluster using `kubectl apply -f <manifest.yaml>`.

1. **Deploy Kube-VIP as a DaemonSet**:
   - You can deploy Kube-VIP as a DaemonSet to ensure it runs on every node in your cluster.
   - Create a DaemonSet YAML file with the necessary configuration or use the provided examples from the Kube-VIP repository.

     **Create a DaemonSet YAML Configuration**:
     - You will need to create a YAML configuration file that defines the DaemonSet for Kube-VIP.
  
     Here's an example configuration:
  
     ```yaml
     apiVersion: apps/v1
     kind: DaemonSet
     metadata:
       name: kube-vip-ds
       namespace: kube-system
     spec:
       selector:
         matchLabels:
           app: kube-vip
       template:
         metadata:
           labels:
             app: kube-vip
         spec:
           hostNetwork: true
           containers:
           - name: kube-vip
             image: ghcr.io/kube-vip/kube-vip:latest
             args:
               - manager
             env:
             - name: vip_arp
               value: "true"
             - name: vip_interface
               value: "eth0"
             - name: vip_address
               value: "192.168.0.100"
             securityContext:
               capabilities:
                 add:
                   - NET_ADMIN
                   - NET_RAW
             volumeMounts:
               - name: kube-vip-config
                 mountPath: /etc/kube-vip/
           volumes:
             - name: kube-vip-config
               configMap:
                 name: kubevip
     ```
  
     Modify the `vip_interface` and `vip_address` values to match your specific network configuration. Ensure the `image` is set to the correct version of Kube-VIP that you want to use.
  
     **Apply the DaemonSet to Your Cluster**:
     - Use `kubectl` to apply the DaemonSet configuration to your K3s cluster:
  
       ```bash
       kubectl apply -f kube-vip-daemonset.yaml
       ```
  
     Replace `kube-vip-daemonset.yaml` with the path to your YAML file.
  
     **Verify the DaemonSet Deployment**:
     - Check that the DaemonSet is created and that the Kube-VIP pods are running on each node:
  
       ```bash
       kubectl get daemonset -n kube-system
       ```
  
     - You should see an entry for `kube-vip-ds`, and the `DESIRED`, `CURRENT`, and `READY` columns should show the same number of pods as you have nodes.
  
     **Check Pod Status**:
     - Verify that the Kube-VIP pods are running:
  
       ```bash
       kubectl get pods -n kube-system -l app=kube-vip
       ```
  
     - Ensure that all the pods are in the `Running` state.
  
     **Test the Virtual IP**:
     - Once the DaemonSet is running, test the virtual IP to ensure it's accessible and correctly routes traffic to your control plane.

1. **Verify the Installation**:
   - Check that the Kube-VIP pods are running correctly using `kubectl get pods -n kube-system`.
   - Ensure that the virtual IP is accessible and routes traffic to your control plane.

1. **Test Failover**:
   - Simulate a node failure to ensure that Kube-VIP correctly fails over the virtual IP to another node.
