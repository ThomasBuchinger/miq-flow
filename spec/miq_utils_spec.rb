# frozen_string_literal: true

require 'spec_helper'
RSpec.describe MiqFlow::MiqMethods::MiqUtils do
  subject{ Object.new.extend(MiqFlow::MiqMethods::MiqUtils) }
  context 'name_from_branch()' do
    let!(:reset_naming){ MiqFlow::Config.update_naming(['-', '/'], 1) }
    it 'defaults to TYPE-NAME-description syntax' do
      name = subject.name_from_branch('feature-f1-description')
      expect(name).to match('f1')
    end
    it 'can be used with TYPE-REF-NAME-description syntax' do
      name = subject.name_from_branch('feature-1-f1-my-awsome-feature', index: 2)
      expect(name).to match('f1')
    end
    it 'is not confused by underscores' do
      name = subject.name_from_branch('feature/f1_part1-my_awsome_feature')
      expect(name).to match('f1_part1')
    end
    it 'can use different separators' do
      name = subject.name_from_branch('feature_f1-part1_my_awsome_feature', separator: ['_'])
      expect(name).to match('f1-part1')
    end
    it 'replaces invalid characters' do
      name = subject.name_from_branch('feature-f!_p@r=1-my_awsome_feature')
      expect(name).to match('f__p_r_1')
    end
    it 'doe nothing if no separator present' do
      name = subject.name_from_branch('my_awsome_feature')
      expect(name).to match('my_awsome_feature')
    end
  end
end
