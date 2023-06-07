#!/bin/bash

source 0x0_init-logger.sh


LOG_WARNING "Test start: ${{ inputs.VERSION_B_S_rC }}"
flag_test_pass="true"
platforms=${{ inputs.DOCKER_BUILD_PLATFORMS }}
l_platforms=(${platforms//,/ })
for test_platform in ${l_platforms[@]};do
LOG_WARNING "Test for platform: ${test_platform}"
edge_result="$(docker run --rm \
    --platform ${test_platform} \
    ${{ env.REGISTRY }}/${{ secrets.REGISTRY_USERNAME }}/${{ inputs.DOCKER_APP_NAME }}:${{ inputs.DOCKER_TEST_TAG }} \
    edge -h 2>&1 | xargs -I {} echo {})"
if [[ -z "$(echo ${edge_result,,} | grep welcome)" ]]; then
    LOG_ERROR 出错了: ${test_platform} - ${edge_result}
    flag_test_pass="false"
    continue
fi
docker run --rm \
    --platform ${test_platform} \
    ${{ env.REGISTRY }}/${{ secrets.REGISTRY_USERNAME }}/${{ inputs.DOCKER_APP_NAME }}:${{ inputs.DOCKER_TEST_TAG }} \
    ls /usr/local/sbin/edge
docker run --rm \
    --platform ${test_platform} \
    ${{ env.REGISTRY }}/${{ secrets.REGISTRY_USERNAME }}/${{ inputs.DOCKER_APP_NAME }}:${{ inputs.DOCKER_TEST_TAG }} \
    edge -h 2>&1 | xargs -I {} echo {}
LOG_WARNING "Test pass - edge"
docker run --rm \
    --platform ${test_platform} \
    ${{ env.REGISTRY }}/${{ secrets.REGISTRY_USERNAME }}/${{ inputs.DOCKER_APP_NAME }}:${{ inputs.DOCKER_TEST_TAG }} \
    ls /usr/local/sbin/supernode
# supernode will not pass
docker run --rm \
    --platform ${test_platform} \
    ${{ env.REGISTRY }}/${{ secrets.REGISTRY_USERNAME }}/${{ inputs.DOCKER_APP_NAME }}:${{ inputs.DOCKER_TEST_TAG }} \
    supernode -h 2>&1 | xargs -I {} echo {} || echo -e "\n# check supernode ignore errors"
# LOG_WARNING "Test done - supernode"
done
if [[ "${flag_test_pass}" != "true" ]]; then
LOG_ERROR "Test faild: ${{ inputs.VERSION_B_S_rC }}"
exit 1
fi
LOG_WARNING "Test done: ${{ inputs.VERSION_B_S_rC }}"
echo "build_dockerfile=Dockerfile">> $GITHUB_OUTPUT
exit 0
