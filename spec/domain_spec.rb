# frozen_string_literal: true

require 'spec_helper'
RSpec.describe MiqFlow::MiqDomain do
  subject do
    opts = {
      provider_name: 'noop',
      export_dir: 'export/dir',
      export_name: 'export_name'
    }
    MiqFlow::MiqDomain.create_from_config('dummy', opts)
  end

  context "_limit_changeset()" do
    it "works as expected" do
      valids = [
        '/tmp/repo/export/dir/export_name/ns/klass.class/__methods__/meth1.rb',
        '/tmp/repo/export/dir/export_name/ns/klass.class/__methods__/meth1.yaml',
        '/tmp/repo/export/dir/export_name/ns/klass.class/__class__.yaml',
        '/tmp/repo/export/dir/export_name/ns/__namespace__.yaml'
      ]
      invalids = [
        '/tmp/repo/export/dir/export_name_sub/ns/klass.class/__methods__/meth1.rb',
        '/tmp/repo/dir/export_name/ns/klass.class/__methods__/meth1.rb'
      ]
      changes = subject._limit_changeset(valids + invalids)
      expect(changes).to match_array(valids)
    end
  end

  context "file_data()" do
    it 'constructs the correct path' do
      re = subject.file_data(git_workdir: '/tmp/', namespace: 'ns', klass: 'klass', name: 'meth1')
      expect(re[:path]).to eq('/tmp/export/dir/export_name/ns/klass.class/__methods__/meth1.rb')
    end
    it 'additional data looks correct' do
      re = subject.file_data(git_workdir: '/tmp/', namespace: 'ns', klass: 'klass', name: 'meth1')
      expect(re[:meta_yaml]).to eq('/tmp/export/dir/export_name/ns/klass.class/__methods__/meth1.yaml')
      expect(re[:content]).to eq('')
      expect(re[:meta_content]).to eq('')
    end
    it 'can read files' do
      allow(File).to receive(:exist?).and_return(true)
      allow(File).to receive(:read).and_return('text')

      re = subject.file_data(git_workdir: '/tmp/', namespace: 'ns', klass: 'klass', name: 'meth1')
      expect(re[:content]).to eq('text')
      expect(re[:meta_content]).to eq('text')
    end
  end
end
