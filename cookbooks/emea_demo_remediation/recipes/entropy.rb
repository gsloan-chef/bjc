package 'rng-tools'

execute 'create more entropy' do
  command 'rngd -r /dev/urandom -o /dev/random'
  only_if { `cat /proc/sys/kernel/random/entropy_avail`.to_i < 1000 }
end
