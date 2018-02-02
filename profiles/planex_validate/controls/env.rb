# encoding: utf-8
# copyright: 2017, The Authors

title 'Evaluate Environment'

control 'env-1.0' do
  impact 1.0
  title 'Validate Apache'
  desc 'Ensure Apache is installed and running'
  describe service('apache2') do
    it { should be_installed }
    it { should be_enabled }
    it { should be_running }
  end
end

control 'env-2.0' do
  impact 1.0
  title 'Validate Java'
  desc 'Ensure Java is installed'
  describe package('java-common') do
    it { should be_installed }
  end
end

control 'env-3.0' do
  impact 1.0
  title 'Validate Tomcat'
  desc 'Ensure Tomcat is installed'
  describe package('tomcat7') do
    it { should be_installed }
  end
end

control 'env-4.0' do
  impact 1.0
  title 'Validate MySQL'
  desc 'Ensure MySQL is installed and running'
  describe service('mysql') do
    it { should be_installed }
    it { should be_running }
  end
end

control 'ports-1.0' do
  impact 0.7
  title 'Web Ports'
  desc 'Ensure Apache is listening on port 443'
  describe port(443) do
    it { should be_listening }
  end
end

control 'ports-2.0' do
  impact 0.7
  title 'DB Ports'
  desc 'Ensure MySQL is listening on port 3306'
  describe port(3306) do
    it { should be_listening }
  end
end
