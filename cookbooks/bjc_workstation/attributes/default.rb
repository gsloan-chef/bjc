default['bjc_workstation']['cookbooks'] = ['bjc-ecommerce', 'bjc_bass', 'dca_demo', 'dca_audit_baseline', 'dca_hardening_linux', 'cm_demo']
default['bjc_workstation']['profiles'] = %w[apache_webserver linux_baseline_wrapper windows_baseline_wrapper planex_validate]
default['bjc_workstation']['startup'] = 'Start_Demo.ps1'