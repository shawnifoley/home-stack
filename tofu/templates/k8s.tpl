[masters]
%{ for master in k3s_master_ips ~}
${master.ip} ansible_ssh_private_key_file=${master.ssh_key}
%{ endfor ~}

[workers]
%{ for worker in k3s_worker_ips ~}
${worker.ip} ansible_ssh_private_key_file=${worker.ssh_key}
%{ endfor ~}

[k3s_cluster:children]
masters
workers
