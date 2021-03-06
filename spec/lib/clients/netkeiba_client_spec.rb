# coding: utf-8

require 'rails_helper'

describe NetkeibaClient do
  describe '#http_get_race_top' do
    dirs = %w[spec fixtures lib clients netkeiba_client http_get_race_top].join('/')
    expected = %w[201905020911 201809030411 201805030411 201709030411 201908030510
                  201609030411 201509030411 201905030211 201705030411 201909020411
                  201409030411 201904010211 201905020809 201605030411 201908031008
                  201809030811 201905020609 201903010511 201906030210 201909020211]

    describe '正常系' do
      before(:all) do
        RSpec::Mocks.with_temporary_scope do
          client = NetkeibaClient.new
          race_top = File.read(Rails.root.join(dirs, 'race_top.html'))
          struct = Struct.new(:body)
          response = struct.new(race_top.encode('UTF-8', 'EUC-JP'))
          allow(client).to receive(:get).and_return(response)
          @response = client.http_get_race_top
        end
      end

      it 'レスポンスが正しいこと' do
        is_asserted_by { @response == expected }
      end
    end
  end

  describe '#http_get_race' do
    dirs = %w[spec fixtures lib clients netkeiba_client http_get_race].join('/')

    describe '正常系' do
      before(:all) do
        RSpec::Mocks.with_temporary_scope do
          client = NetkeibaClient.new
          race = File.read(Rails.root.join(dirs, 'race.html'))
          struct = Struct.new(:body)
          response = struct.new(race)
          allow(client).to receive(:get).and_return(response)
          @response = client.http_get_race('dummy')
        end
      end

      it 'レスポンスが正しいこと' do
        expected_yml = Rails.root.join(dirs, 'expected_race.yml')
        is_asserted_by { @response == YAML.load_file(expected_yml).deep_symbolize_keys }
      end
    end
  end

  describe '#http_get_horse' do
    dirs = %w[spec fixtures lib clients netkeiba_client http_get_horse].join('/')

    describe '正常系' do
      before(:all) do
        RSpec::Mocks.with_temporary_scope do
          client = NetkeibaClient.new
          horse = File.read(Rails.root.join(dirs, 'horse.html'))
          struct = Struct.new(:body)
          response = struct.new(horse)
          allow(client).to receive(:get).and_return(response)
          @response = client.http_get_horse('dummy')
        end
      end

      it 'レスポンスが正しいこと' do
        expected_yml = Rails.root.join(dirs, 'expected_horse.yml')
        is_asserted_by { @response == YAML.load_file(expected_yml).deep_symbolize_keys }
      end
    end
  end

  describe '#http_get_jockey' do
    dirs = %w[spec fixtures lib clients netkeiba_client http_get_jockey].join('/')

    describe '正常系' do
      before(:all) do
        RSpec::Mocks.with_temporary_scope do
          client = NetkeibaClient.new
          jockey = File.read(Rails.root.join(dirs, 'jockey.html'))
          struct = Struct.new(:body)
          response = struct.new(jockey)
          allow(client).to receive(:get).and_return(response)
          @response = client.http_get_jockey('dummy')
        end
      end

      it 'レスポンスが正しいこと' do
        expected_yml = Rails.root.join(dirs, 'expected_jockey.yml')
        is_asserted_by { @response == YAML.load_file(expected_yml).deep_symbolize_keys }
      end
    end
  end
end
