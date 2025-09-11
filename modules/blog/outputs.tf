output "environment_url" {
    value = module.blog_alb.lb_dns_name
}

output "target_group_name" {
    value = module.blog_alb.target_group_names 
}