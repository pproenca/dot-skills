---
title: Raise vm.max_map_count to 524288 on the host before first boot
tags: ops, docker, kernel-limits, elasticsearch
---

## Raise vm.max_map_count to 524288 on the host before first boot

SonarQube embeds Elasticsearch, which refuses to start under the default kernel memory-map limit. The container exits during startup with an Elasticsearch bootstrap check failure, which reads as an application crash rather than a host misconfiguration and sends people looking in the wrong place.

The value most guides cite is `262144`, carried over from older Elasticsearch requirements. The current requirement is **double that**: `vm.max_map_count` must be at least **524288**. Setting the older value produces the same startup failure with a slightly different number in the message.

These are **host** settings, not container settings — *"these settings will then apply to the Docker container"* — so they cannot be fixed from the compose file:

```bash
# Apply now, and persist across reboots.
sudo sysctl -w vm.max_map_count=524288
sudo sysctl -w fs.file-max=131072
printf 'vm.max_map_count=524288\nfs.file-max=131072\n' | sudo tee /etc/sysctl.d/99-sonarqube.conf

# Per-user limits for the account running the container.
# sonarqube   -   nofile   131072
# sonarqube   -   nproc    8192
```

Under systemd the equivalents are `LimitNOFILE=131072` and `LimitNPROC=8192` on the unit. Docker Engine 20.10 or later is recommended.

On managed container platforms where the host kernel is not yours to configure — most Kubernetes-as-a-service offerings, Fargate, Cloud Run — this requirement is the constraint that decides the deployment shape, and it is better discovered while choosing the platform than during the first deploy. The usual answers are a privileged init container that runs `sysctl` before the main container starts, a node pool with a custom kernel configuration, or a managed VM instead.

This is a first-boot problem and then never again, which is precisely why it is worth writing down: by the time the instance needs rebuilding on new infrastructure, nobody remembers that the working host was tuned.

Reference: [Set up and start the container](https://docs.sonarsource.com/sonarqube-server/server-installation/from-docker-image/set-up-and-start-container) · [Linux pre-installation](https://docs.sonarsource.com/sonarqube-server/server-installation/pre-installation/linux)
