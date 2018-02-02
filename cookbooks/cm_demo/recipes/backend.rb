# Only check the backend if this recipe is in use
node.override['audit']['profiles'] = [
  {
    name: 'Linux Baseline',
    compliance: 'workstation-1/cm_backend',
  },
]


include_recipe 'bjc-ecommerce::mysql'
