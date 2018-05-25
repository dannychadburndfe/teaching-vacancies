require 'rails_helper'
require 'modules/aws_ip_ranges'

RSpec.describe AWSIpRanges do
  describe '.cloudfront_ips' do
    before(:each) do
      aws_ip_ranges = File.read(Rails.root.join('spec', 'fixtures', 'aws_ip_ranges.json'))

      stub_request(:get, AWSIpRanges::PATH)
        .to_return(body: aws_ip_ranges, status: 200)
    end

    it 'returns the CLOUDFRONT ip in the GLOBAL area' do
      expected_result = [
        '13.32.0.0/15',
        '13.35.0.0/16',
        '52.46.0.0/18',
        '52.84.0.0/15',
        '52.124.128.0/17',
        '52.222.128.0/17',
        '54.182.0.0/16',
        '54.192.0.0/16',
        '54.230.0.0/16',
        '54.239.128.0/18',
        '54.239.192.0/19',
        '54.240.128.0/18',
        '64.252.64.0/18',
        '70.132.0.0/18',
        '71.152.0.0/17',
        '143.204.0.0/16',
        '204.246.164.0/22',
        '204.246.168.0/22',
        '204.246.174.0/23',
        '204.246.176.0/20',
        '205.251.192.0/19',
        '205.251.249.0/24',
        '205.251.250.0/23',
        '205.251.252.0/23',
        '205.251.254.0/24',
        '216.137.32.0/19'
      ]

      expect(AWSIpRanges.cloudfront_ips).to eql(expected_result)
    end

    context 'when there was any connectivity issue' do
      it 'returns an empty array' do
        allow(Net::HTTP).to receive(:get).and_raise(Timeout::Error.new('error'))
        expect(AWSIpRanges.cloudfront_ips).to eql([])
      end

      it 'logs a warning' do
        allow(Net::HTTP).to receive(:get).and_raise(Timeout::Error.new('error'))
        expect(Rails.logger)
          .to receive(:warn)
          .with('Unable to setup Rack Proxies to acquire the correct remote_ip: Timeout::Error')
        AWSIpRanges.cloudfront_ips
      end
    end

    context 'when we see other types of Net::HTTP error' do
      [
        Errno::EINVAL,
        Errno::ECONNRESET,
        EOFError,
        Net::HTTPBadResponse,
        Net::HTTPHeaderSyntaxError,
        Net::ProtocolError
      ].each do |error|
        context "when #{error} is raised" do
          it 'returns an empty array' do
            allow(Net::HTTP).to receive(:get).and_raise(error.new('error'))
            expect(AWSIpRanges.cloudfront_ips).to eql([])
          end
        end
      end
    end
  end
end
