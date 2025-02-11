from typing import List, Type
from kube_hound.analysis import Analysis
from kube_hound.builtin_analyses.exposed_services_external_ip import ExposedServicesWithExternalIp
from kube_hound.builtin_analyses.multiple_user_authentication_openapi import MultipleUserAuthenticationOpenAPI
from kube_hound.builtin_analyses.unnecessary_privileges_pods import UnnecessaryPrivilegesToPods
from kube_hound.builtin_analyses.insufficient_access_control_openapi import InsufficientAccessControlOpenAPI
from kube_hound.builtin_analyses.hardcoded_secrets_environment import HardcodedSecretsInEnvironment
from kube_hound.builtin_analyses.unencrypted_pod_to_pod_traffic import UnencryptedPodToPodTraffic
from kube_hound.builtin_analyses.hardcoded_unencrypted_kubernetes_secrets import HardcodedSecretsInKubernetes
from kube_hound.builtin_analyses.hardcoded_docker_source_secrets import HardcodedSecretsInDockerAndSource
from kube_hound.builtin_analyses.dbms_data_at_rest_encryption import DBMSDataAtRestEncryption

all_analyses: List[Type[Analysis]] = [
    ExposedServicesWithExternalIp,
    UnnecessaryPrivilegesToPods,
    InsufficientAccessControlOpenAPI,
    MultipleUserAuthenticationOpenAPI,
    HardcodedSecretsInEnvironment,
    UnencryptedPodToPodTraffic,
    HardcodedSecretsInKubernetes,
    HardcodedSecretsInDockerAndSource,
    DBMSDataAtRestEncryption,
]
