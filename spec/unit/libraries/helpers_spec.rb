require_relative '../../spec_helper'
require_relative '../../../libraries/helpers'

RSpec.describe OslDocker::Cookbook::Helpers do
  let(:new_resource) do
    double(
      'new_resource',
      name: 'test-compose',
      directory: '/var/lib/compose',
      config_files: ['docker-compose.yml']
    )
  end

  let(:dummy_class) do
    Class.new do
      include OslDocker::Cookbook::Helpers
      attr_accessor :new_resource

      def shell_out(cmd, options = {})
        # This will be stubbed in tests
      end
    end
  end

  subject do
    instance = dummy_class.new
    instance.new_resource = new_resource
    instance
  end

  describe '#osl_dockercompose_running?' do
    let(:shell_out_result) { double('shell_out_result', exitstatus: exitstatus, stdout: stdout) }

    before do
      allow(subject).to receive(:shell_out).and_return(shell_out_result)
    end

    context 'when all containers are running' do
      let(:exitstatus) { 0 }
      let(:stdout) do
        <<~JSON
          {"Name":"test-compose-web-1","State":"running","Status":"Up 5 minutes"}
          {"Name":"test-compose-db-1","State":"running","Status":"Up 5 minutes"}
        JSON
      end

      it 'returns true' do
        expect(subject.osl_dockercompose_running?).to eq true
      end

      it 'calls docker compose ps with correct arguments' do
        subject.osl_dockercompose_running?
        expect(subject).to have_received(:shell_out).with(
          'docker compose -p test-compose -f docker-compose.yml ps -a --format json',
          cwd: '/var/lib/compose'
        )
      end
    end

    context 'when some containers are stopped' do
      let(:exitstatus) { 0 }
      let(:stdout) do
        <<~JSON
          {"Name":"test-compose-web-1","State":"running","Status":"Up 5 minutes"}
          {"Name":"test-compose-db-1","State":"exited","Status":"Exited (1) 2 minutes ago"}
        JSON
      end

      it 'returns false' do
        expect(subject.osl_dockercompose_running?).to eq false
      end
    end

    context 'when all containers are stopped' do
      let(:exitstatus) { 0 }
      let(:stdout) do
        <<~JSON
          {"Name":"test-compose-web-1","State":"exited","Status":"Exited (0) 10 minutes ago"}
          {"Name":"test-compose-db-1","State":"exited","Status":"Exited (1) 10 minutes ago"}
        JSON
      end

      it 'returns false' do
        expect(subject.osl_dockercompose_running?).to eq false
      end
    end

    context 'when no containers exist' do
      let(:exitstatus) { 0 }
      let(:stdout) { '' }

      it 'returns false' do
        expect(subject.osl_dockercompose_running?).to eq false
      end
    end

    context 'when docker compose ps command fails' do
      let(:exitstatus) { 1 }
      let(:stdout) { '' }

      before do
        allow(Chef::Log).to receive(:debug)
      end

      it 'returns false' do
        expect(subject.osl_dockercompose_running?).to eq false
      end

      it 'logs a debug message' do
        subject.osl_dockercompose_running?
        expect(Chef::Log).to have_received(:debug).with(
          'docker compose ps failed for test-compose, assuming not running'
        )
      end
    end

    context 'with multiple config files' do
      let(:new_resource) do
        double(
          'new_resource',
          name: 'multi-config',
          directory: '/opt/services',
          config_files: ['docker-compose.yml', 'docker-compose.override.yml']
        )
      end
      let(:exitstatus) { 0 }
      let(:stdout) do
        <<~JSON
          {"Name":"multi-config-service-1","State":"running","Status":"Up 1 hour"}
        JSON
      end

      it 'includes all config files in the command' do
        subject.osl_dockercompose_running?
        expect(subject).to have_received(:shell_out).with(
          'docker compose -p multi-config -f docker-compose.yml -f docker-compose.override.yml ps -a --format json',
          cwd: '/opt/services'
        )
      end
    end

    context 'with no config files specified' do
      let(:new_resource) do
        double(
          'new_resource',
          name: 'no-configs',
          directory: '/var/lib/compose',
          config_files: []
        )
      end
      let(:exitstatus) { 0 }
      let(:stdout) do
        <<~JSON
          {"Name":"no-configs-app-1","State":"running","Status":"Up 30 seconds"}
        JSON
      end

      it 'works without -f flags' do
        subject.osl_dockercompose_running?
        expect(subject).to have_received(:shell_out).with(
          'docker compose -p no-configs  ps -a --format json',
          cwd: '/var/lib/compose'
        )
      end
    end

    context 'when container has different states' do
      let(:exitstatus) { 0 }

      [
        { state: 'restarting', expected: false },
        { state: 'paused', expected: false },
        { state: 'dead', expected: false },
        { state: 'created', expected: false },
        { state: 'removing', expected: false },
      ].each do |test_case|
        context "when state is #{test_case[:state]}" do
          let(:stdout) do
            <<~JSON
              {"Name":"test-compose-web-1","State":"#{test_case[:state]}","Status":"..."}
            JSON
          end

          it "returns #{test_case[:expected]}" do
            expect(subject.osl_dockercompose_running?).to eq test_case[:expected]
          end
        end
      end
    end

    context 'with mixed line endings' do
      let(:exitstatus) { 0 }
      let(:stdout) { "{\"Name\":\"test-1\",\"State\":\"running\"}\r\n{\"Name\":\"test-2\",\"State\":\"running\"}\n" }

      it 'handles both CRLF and LF line endings' do
        expect(subject.osl_dockercompose_running?).to eq true
      end
    end

    context 'with empty lines in output' do
      let(:exitstatus) { 0 }
      let(:stdout) do
        <<~JSON
          {"Name":"test-1","State":"running"}

          {"Name":"test-2","State":"running"}
        JSON
      end

      it 'ignores empty lines' do
        expect(subject.osl_dockercompose_running?).to eq true
      end
    end
  end
end
