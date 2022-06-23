locals {
  organization_id           = var.parent_folder != "" ? null : var.organization_id
  folder_id                 = var.parent_folder != "" ? var.parent_folder : null
  policy_for                = var.parent_folder != "" ? "folder" : "organization"
  enforced_boolean_policies = { for item in var.enforced_boolean_policies : item => item }
}

/******************************************
  Cloud Function org policies
*******************************************/
resource "google_organization_policy" "boolean_policies" {
  for_each   = local.enforced_boolean_policies
  constraint = each.value
  org_id     = var.organization_id

  boolean_policy {
    enforced = true
  }
}

module "org_cf_allow_ingress" {
  count             = length(var.org_cf_allow_ingress) > 0 ? 1 : 0
  source            = "terraform-google-modules/org-policy/google"
  version           = "~> 3.0"
  organization_id   = local.organization_id
  folder_id         = local.folder_id
  policy_for        = local.policy_for
  constraint        = "constraints/cloudfunctions.allowedIngressSettings"
  policy_type       = "list"
  allow             = var.org_cf_allow_ingress
  allow_list_length = length(var.org_cf_allow_ingress)
}

module "org_cf_allowed_vpc" {
  count             = length(var.org_cf_allowed_vpc) > 0 ? 1 : 0
  source            = "terraform-google-modules/org-policy/google"
  version           = "~> 3.0"
  organization_id   = local.organization_id
  folder_id         = local.folder_id
  policy_for        = local.policy_for
  policy_type       = "list"
  allow             = var.org_cf_allowed_vpc
  allow_list_length = length(var.org_cf_allowed_vpc)
  constraint        = "constraints/cloudfunctions.allowedVpcConnectorEgressSettings"
}

module "org_cs_retention_policy" {
  count             = length(var.org_cs_retention_policy) > 0 ? 1 : 0
  source            = "terraform-google-modules/org-policy/google"
  version           = "~> 3.0"
  organization_id   = local.organization_id
  folder_id         = local.folder_id
  policy_for        = local.policy_for
  policy_type       = "list"
  allow             = var.org_cs_retention_policy
  allow_list_length = length(var.org_cs_retention_policy)
  constraint        = "constraints/storage.retentionPolicySeconds"
}

module "org_compute_restrict_lb" {
  count             = length(var.org_compute_restrict_lb_allow) + length(var.org_compute_restrict_lb_deny) > 0 ? 1 : 0
  source            = "terraform-google-modules/org-policy/google"
  version           = "~> 3.0"
  organization_id   = local.organization_id
  folder_id         = local.folder_id
  policy_for        = local.policy_for
  policy_type       = "list"
  allow             = var.org_compute_restrict_lb_allow
  allow_list_length = length(var.org_compute_restrict_lb_allow)
  deny              = var.org_compute_restrict_lb_deny
  deny_list_length  = length(var.org_compute_restrict_lb_deny)
  constraint        = "constraints/compute.restrictLoadBalancerCreationForTypes"
}

module "org_compute_restrict_nonconfidential" {
  count            = length(var.org_compute_restrict_nonconfidential) > 0 ? 1 : 0
  source           = "terraform-google-modules/org-policy/google"
  version          = "~> 3.0"
  organization_id  = local.organization_id
  folder_id        = local.folder_id
  policy_for       = local.policy_for
  policy_type      = "list"
  deny             = var.org_compute_restrict_nonconfidential
  deny_list_length = length(var.org_compute_restrict_nonconfidential)
  constraint       = "constraints/compute.restrictNonConfidentialComputing"
}

module "org_compute_trusted_images" {
  count             = length(var.allow_images_projects) > 0 ? 1 : 0
  source            = "terraform-google-modules/org-policy/google"
  version           = "~> 3.0"
  organization_id   = local.organization_id
  folder_id         = local.folder_id
  policy_for        = local.policy_for
  policy_type       = "list"
  allow             = var.allow_images_projects
  allow_list_length = length(var.allow_images_projects)
  constraint        = "constraints/compute.trustedImageProjects"
}

module "org_network_private_connect" {
  count             = length(var.org_compute_private_connect_allow) + length(var.org_compute_private_connect_deny) > 0 ? 1 : 0
  source            = "terraform-google-modules/org-policy/google"
  version           = "~> 3.0"
  organization_id   = local.organization_id
  folder_id         = local.folder_id
  policy_for        = local.policy_for
  policy_type       = "list"
  allow             = var.org_compute_private_connect_allow
  allow_list_length = length(var.org_compute_private_connect_allow)
  deny              = var.org_compute_private_connect_deny
  deny_list_length  = length(var.org_compute_private_connect_deny)
  constraint        = "constraints/compute.disablePrivateServiceConnectCreationForConsumers"
}

module "org_compute_restrict_forwarding" {
  count             = length(var.org_compute_restrict_forwarding_allow) + length(var.org_compute_restrict_forwarding_deny) > 0 ? 1 : 0
  source            = "terraform-google-modules/org-policy/google"
  version           = "~> 3.0"
  organization_id   = local.organization_id
  folder_id         = local.folder_id
  policy_for        = local.policy_for
  policy_type       = "list"
  allow             = var.org_compute_restrict_forwarding_allow
  allow_list_length = length(var.org_compute_restrict_forwarding_allow)
  deny              = var.org_compute_restrict_forwarding_deny
  deny_list_length  = length(var.org_compute_restrict_forwarding_deny)
  constraint        = "constraints/compute.restrictProtocolForwardingCreationForTypes"
}

module "org_compute_restrict_svpc" {
  count             = length(var.org_compute_restrict_svpc_allow) + length(var.org_compute_restrict_svpc_deny) > 0 ? 1 : 0
  source            = "terraform-google-modules/org-policy/google"
  version           = "~> 3.0"
  organization_id   = local.organization_id
  folder_id         = local.folder_id
  policy_for        = local.policy_for
  policy_type       = "list"
  allow             = var.org_compute_restrict_svpc_allow
  allow_list_length = length(var.org_compute_restrict_svpc_allow)
  deny              = var.org_compute_restrict_svpc_deny
  deny_list_length  = length(var.org_compute_restrict_svpc_deny)
  constraint        = "constraints/compute.restrictSharedVpcHostProjects"
}

module "org_compute_restrict_svpc_subnet" {
  count             = length(var.org_compute_restrict_svpc_subnet_allow) + length(var.org_compute_restrict_svpc_subnet_deny) > 0 ? 1 : 0
  source            = "terraform-google-modules/org-policy/google"
  version           = "~> 3.0"
  organization_id   = local.organization_id
  folder_id         = local.folder_id
  policy_for        = local.policy_for
  policy_type       = "list"
  allow             = var.org_compute_restrict_svpc_subnet_allow
  allow_list_length = length(var.org_compute_restrict_svpc_subnet_allow)
  deny              = var.org_compute_restrict_svpc_subnet_deny
  deny_list_length  = length(var.org_compute_restrict_svpc_subnet_deny)
  constraint        = "constraints/compute.restrictSharedVpcSubnetworks"
}

module "org_compute_restrict_vpc_peers" {
  count             = length(var.org_compute_restrict_vpc_peers_allow) + length(var.org_compute_restrict_vpc_peers_deny) > 0 ? 1 : 0
  source            = "terraform-google-modules/org-policy/google"
  version           = "~> 3.0"
  organization_id   = local.organization_id
  folder_id         = local.folder_id
  policy_for        = local.policy_for
  policy_type       = "list"
  allow             = var.org_compute_restrict_vpc_peers_allow
  allow_list_length = length(var.org_compute_restrict_vpc_peers_allow)
  deny              = var.org_compute_restrict_vpc_peers_deny
  deny_list_length  = length(var.org_compute_restrict_vpc_peers_deny)
  constraint        = "constraints/compute.restrictVpcPeering"
}

module "org_compute_restrict_storage" {
  count             = length(var.org_compute_restrict_storage_allow) + length(var.org_compute_restrict_storage_deny) > 0 ? 1 : 0
  source            = "terraform-google-modules/org-policy/google"
  version           = "~> 3.0"
  organization_id   = local.organization_id
  folder_id         = local.folder_id
  policy_for        = local.policy_for
  policy_type       = "list"
  allow             = var.org_compute_restrict_storage_allow
  allow_list_length = length(var.org_compute_restrict_storage_allow)
  deny              = var.org_compute_restrict_storage_deny
  deny_list_length  = length(var.org_compute_restrict_storage_deny)
  constraint        = "constraints/compute.storageResourceUseRestrictions"
}

module "org_compute_restrict_ipforwarding" {
  count             = length(var.org_compute_restrict_ipforwarding_allow) + length(var.org_compute_restrict_ipforwarding_deny) > 0 ? 1 : 0
  source            = "terraform-google-modules/org-policy/google"
  version           = "~> 3.0"
  organization_id   = local.organization_id
  folder_id         = local.folder_id
  policy_for        = local.policy_for
  policy_type       = "list"
  allow             = var.org_compute_restrict_ipforwarding_allow
  allow_list_length = length(var.org_compute_restrict_ipforwarding_allow)
  deny              = var.org_compute_restrict_ipforwarding_deny
  deny_list_length  = length(var.org_compute_restrict_ipforwarding_deny)
  constraint        = "constraints/compute.vmCanIpForward"
}

module "org_compute_externalips" {
  count             = length(var.org_compute_externalips_allow) + length(var.org_compute_externalips_deny) > 0 ? 1 : 0
  source            = "terraform-google-modules/org-policy/google"
  version           = "~> 3.0"
  organization_id   = local.organization_id
  folder_id         = local.folder_id
  policy_for        = local.policy_for
  policy_type       = "list"
  allow             = var.org_compute_externalips_allow
  allow_list_length = length(var.org_compute_externalips_allow)
  deny              = var.org_compute_externalips_deny
  deny_list_length  = length(var.org_compute_externalips_deny)
  constraint        = "constraints/compute.vmExternalIpAccess"
}

module "org_compute_vpnips" {
  count             = length(var.org_compute_vpnips_allow) + length(var.org_compute_vpnips_deny) > 0 ? 1 : 0
  source            = "terraform-google-modules/org-policy/google"
  version           = "~> 3.0"
  organization_id   = local.organization_id
  folder_id         = local.folder_id
  policy_for        = local.policy_for
  policy_type       = "list"
  allow             = var.org_compute_vpnips_allow
  allow_list_length = length(var.org_compute_vpnips_allow)
  deny              = var.org_compute_vpnips_deny
  deny_list_length  = length(var.org_compute_vpnips_deny)
  constraint        = "constraints/compute.restrictVpnPeerIPs"
}

module "org_compute_restrict_cloudnat" {
  count             = length(var.org_compute_restrict_cloudnat_allow) + length(var.org_compute_restrict_cloudnat_deny) > 0 ? 1 : 0
  source            = "terraform-google-modules/org-policy/google"
  version           = "~> 3.0"
  organization_id   = local.organization_id
  folder_id         = local.folder_id
  policy_for        = local.policy_for
  policy_type       = "list"
  allow             = var.org_compute_restrict_cloudnat_allow
  allow_list_length = length(var.org_compute_restrict_cloudnat_allow)
  deny              = var.org_compute_restrict_cloudnat_deny
  deny_list_length  = length(var.org_compute_restrict_cloudnat_deny)
  constraint        = "constraints/compute.restrictCloudNATUsage"
}

module "org_compute_restrict_dedicatedinter" {
  count             = length(var.org_compute_restrict_dedicatedinter_allow) + length(var.org_compute_restrict_dedicatedinter_deny) > 0 ? 1 : 0
  source            = "terraform-google-modules/org-policy/google"
  version           = "~> 3.0"
  organization_id   = local.organization_id
  folder_id         = local.folder_id
  policy_for        = local.policy_for
  policy_type       = "list"
  allow             = var.org_compute_restrict_dedicatedinter_allow
  allow_list_length = length(var.org_compute_restrict_dedicatedinter_allow)
  deny              = var.org_compute_restrict_dedicatedinter_deny
  deny_list_length  = length(var.org_compute_restrict_dedicatedinter_deny)
  constraint        = "constraints/compute.restrictDedicatedInterconnectUsage"
}

module "org_compute_restrict_partnerinter" {
  count             = length(var.org_compute_restrict_partnerinter_allow) + length(var.org_compute_restrict_partnerinter_deny) > 0 ? 1 : 0
  source            = "terraform-google-modules/org-policy/google"
  version           = "~> 3.0"
  organization_id   = local.organization_id
  folder_id         = local.folder_id
  policy_for        = local.policy_for
  policy_type       = "list"
  allow             = var.org_compute_restrict_partnerinter_allow
  allow_list_length = length(var.org_compute_restrict_partnerinter_allow)
  deny              = var.org_compute_restrict_partnerinter_deny
  deny_list_length  = length(var.org_compute_restrict_partnerinter_deny)
  constraint        = "constraints/compute.restrictPartnerInterconnectUsage"
}

module "org_contacts_allowed_domains" {
  count             = length(var.org_contacts_allowed_domains_allow) + length(var.org_contacts_allowed_domains_deny) > 0 ? 1 : 0
  source            = "terraform-google-modules/org-policy/google"
  version           = "~> 3.0"
  organization_id   = local.organization_id
  folder_id         = local.folder_id
  policy_for        = local.policy_for
  policy_type       = "list"
  allow             = var.org_contacts_allowed_domains_allow
  allow_list_length = length(var.org_contacts_allowed_domains_allow)
  deny              = var.org_contacts_allowed_domains_deny
  deny_list_length  = length(var.org_contacts_allowed_domains_deny)
  constraint        = "constraints/essentialcontacts.allowedContactDomains"
}

module "org_iam_allowed_members" {
  count             = length(var.org_iam_allowed_members_allow) + length(var.org_iam_allowed_members_deny) > 0 ? 1 : 0
  source            = "terraform-google-modules/org-policy/google"
  version           = "~> 3.0"
  organization_id   = local.organization_id
  folder_id         = local.folder_id
  policy_for        = local.policy_for
  policy_type       = "list"
  allow             = var.org_iam_allowed_members_allow
  allow_list_length = length(var.org_iam_allowed_members_allow)
  deny              = var.org_iam_allowed_members_deny
  deny_list_length  = length(var.org_iam_allowed_members_deny)
  constraint        = "constraints/iam.allowedPolicyMemberDomains"
}

module "org_iam_workload_pool" {
  count             = length(var.org_iam_workload_pool_allow) + length(var.org_iam_workload_pool_deny) > 0 ? 1 : 0
  source            = "terraform-google-modules/org-policy/google"
  version           = "~> 3.0"
  organization_id   = local.organization_id
  folder_id         = local.folder_id
  policy_for        = local.policy_for
  policy_type       = "list"
  allow             = var.org_iam_workload_pool_allow
  allow_list_length = length(var.org_iam_workload_pool_allow)
  deny              = var.org_iam_workload_pool_deny
  deny_list_length  = length(var.org_iam_workload_pool_deny)
  constraint        = "constraints/iam.workloadIdentityPoolProviders"
}

module "org_iam_allow_sa_lifetime" {
  count             = length(var.org_iam_allow_sa_lifetime_allow) + length(var.org_iam_allow_sa_lifetime_deny) > 0 ? 1 : 0
  source            = "terraform-google-modules/org-policy/google"
  version           = "~> 3.0"
  organization_id   = local.organization_id
  folder_id         = local.folder_id
  policy_for        = local.policy_for
  policy_type       = "list"
  allow             = var.org_iam_allow_sa_lifetime_allow
  allow_list_length = length(var.org_iam_allow_sa_lifetime_allow)
  deny              = var.org_iam_allow_sa_lifetime_deny
  deny_list_length  = length(var.org_iam_allow_sa_lifetime_deny)
  constraint        = "constraints/iam.allowServiceAccountCredentialLifetimeExtension"
}