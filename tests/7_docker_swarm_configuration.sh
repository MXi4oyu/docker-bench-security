#!/bin/sh

check_7() {
  logit "\n"
  info "7 - docker集群配置"
}

# 7.1
check_7_1() {
  check_7_1="7.1  - 不启用群集模式"
  totalChecks=$((totalChecks + 1))
  if docker info 2>/dev/null | grep -e "Swarm:*\sinactive\s*" >/dev/null 2>&1; then
    pass "$check_7_1"
    logjson "7.1" "PASS"
    currentScore=$((currentScore + 1))
  else
    warn "$check_7_1"
    logjson "7.1" "WARN"
    currentScore=$((currentScore - 1))
  fi
}

# 7.2
check_7_2() {
  check_7_2="7.2  - 在群集中最小数量创建管理器节点"
  totalChecks=$((totalChecks + 1))
  if docker info 2>/dev/null | grep -e "Swarm:*\sactive\s*" >/dev/null 2>&1; then
    managernodes=$(docker node ls | grep -c "Leader")
    if [ "$managernodes" -le 1 ]; then
      pass "$check_7_2"
      logjson "7.2" "PASS"
      currentScore=$((currentScore + 1))
    else
      warn "$check_7_2"
      logjson "7.2" "WARN"
      currentScore=$((currentScore - 1))
    fi
  else
    pass "$check_7_2 (Swarm mode not enabled)"
    logjson "7.2" "PASS"
    currentScore=$((currentScore + 1))
  fi
}

# 7.3
check_7_3() {
  check_7_3="7.3  - 群集服务绑定到特定的主机接口"
  totalChecks=$((totalChecks + 1))
  if docker info 2>/dev/null | grep -e "Swarm:*\sactive\s*" >/dev/null 2>&1; then
    ss -lnt | grep -e '\[::]:2377 ' -e ':::2377' -e '*:2377 ' -e ' 0\.0\.0\.0:2377 ' >/dev/null 2>&1
    if [ $? -eq 1 ]; then
      pass "$check_7_3"
      logjson "7.3" "PASS"
      currentScore=$((currentScore + 1))
    else
      warn "$check_7_3"
      logjson "7.3" "WARN"
      currentScore=$((currentScore - 1))
    fi
  else
    pass "$check_7_3 (Swarm mode not enabled)"
    logjson "7.3" "PASS"
    currentScore=$((currentScore + 1))
  fi
}

# 7.4
check_7_4(){
  check_7_4="7.4  - 容器之前交换的数据在覆盖网络上的不同节点上就行加密"
  totalChecks=$((totalChecks + 1))
  if docker network ls --filter driver=overlay --quiet | \
    xargs docker network inspect --format '{{.Name}} {{ .Options }}' 2>/dev/null | \
      grep -v 'encrypted:' 2>/dev/null 1>&2; then
    warn "$check_7_4"
    currentScore=$((currentScore - 1))
    for encnet in $(docker network ls --filter driver=overlay --quiet); do
      if docker network inspect --format '{{.Name}} {{ .Options }}' "$encnet" | \
        grep -v 'encrypted:' 2>/dev/null 1>&2; then
        warn "     * Unencrypted overlay network: $(docker network inspect --format '{{ .Name }} ({{ .Scope }})' "$encnet")"
        logjson "7.4" "WARN: $(docker network inspect --format '{{ .Name }} ({{ .Scope }})' "$encnet")"
      fi
    done
  else
    pass "$check_7_4"
    logjson "7.4" "PASS"
    currentScore=$((currentScore + 1))
  fi
}

# 7.5
check_7_5() {
  check_7_5="7.5  - docker的秘密管理命令用户管理Swarm集群中的秘密"
  totalChecks=$((totalChecks + 1))
  if docker info 2>/dev/null | grep -e "Swarm:\s*active\s*" >/dev/null 2>&1; then
    if [ "$(docker secret ls -q | wc -l)" -ge 1 ]; then
      pass "$check_7_5"
      logjson "7.5" "PASS"
      currentScore=$((currentScore + 1))
    else
      info "$check_7_5"
      logjson "7.5" "INFO"
      currentScore=$((currentScore + 0))
    fi
  else
    pass "$check_7_5 (Swarm mode not enabled)"
    logjson "7.5" "PASS"
    currentScore=$((currentScore + 1))
  fi
}

# 7.6
check_7_6() {
  check_7_6="7.6  - swarm manager在自动锁定模式下运行"
  totalChecks=$((totalChecks + 1))
  if docker info 2>/dev/null | grep -e "Swarm:\s*active\s*" >/dev/null 2>&1; then
    if ! docker swarm unlock-key 2>/dev/null | grep 'SWMKEY' 2>/dev/null 1>&2; then
      warn "$check_7_6"
      logjson "7.6" "WARN"
      currentScore=$((currentScore - 1))
    else
      pass "$check_7_6"
      logjson "7.6" "PASS"
      currentScore=$((currentScore + 1))
    fi
  else
    pass "$check_7_6 (Swarm mode not enabled)"
    logjson "7.6" "PASS"
    currentScore=$((currentScore + 1))
  fi
}

# 7.7
check_7_7() {
  check_7_7="7.7  - swarm manager自动锁定键被周期性的轮换"
  totalChecks=$((totalChecks + 1))
  if docker info 2>/dev/null | grep -e "Swarm:\s*active\s*" >/dev/null 2>&1; then
    note "$check_7_7"
    logjson "7.7" "NOTE"
    currentScore=$((currentScore + 0))
  else
    pass "$check_7_7 (Swarm mode not enabled)"
    logjson "7.7" "PASS"
    currentScore=$((currentScore + 1))
  fi
}

# 7.8
check_7_8() {
  check_7_8="7.8  - 节点证书适当轮换"
  totalChecks=$((totalChecks + 1))
  if docker info 2>/dev/null | grep -e "Swarm:\s*active\s*" >/dev/null 2>&1; then
    if docker info 2>/dev/null | grep "Expiry Duration: 2 days"; then
      pass "$check_7_8"
      logjson "7.8" "PASS"
      currentScore=$((currentScore + 1))
    else
      info "$check_7_8"
      logjson "7.8" "INFO"
      currentScore=$((currentScore + 0))
    fi
  else
    pass "$check_7_8 (Swarm mode not enabled)"
    logjson "7.8" "PASS"
    currentScore=$((currentScore + 1))
  fi
}

# 7.9
check_7_9() {
  check_7_9="7.9  - CA根证书根据需要进行轮换"
  totalChecks=$((totalChecks + 1))
  if docker info 2>/dev/null | grep -e "Swarm:\s*active\s*" >/dev/null 2>&1; then
    info "$check_7_9"
    logjson "7.9" "INFO"
    currentScore=$((currentScore + 0))
  else
    pass "$check_7_9 (Swarm mode not enabled)"
    logjson "7.9" "PASS"
    currentScore=$((currentScore + 1))
  fi
}

# 7.10
check_7_10() {
  check_7_10="7.10 - 管理平面流量与数据平面流量分离"
  totalChecks=$((totalChecks + 1))
  if docker info 2>/dev/null | grep -e "Swarm:\s*active\s*" >/dev/null 2>&1; then
    info "$check_7_10"
    logjson "7.10" "INFO"
    currentScore=$((currentScore + 0))
  else
    pass "$check_7_10 (Swarm mode not enabled)"
    logjson "7.10" "PASS"
    currentScore=$((currentScore + 1))
  fi
}
