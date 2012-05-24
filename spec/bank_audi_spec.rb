require 'spec_helper'

describe BankAudi do
  describe 'Request' do

    before :each do
      @request = BankAudi::Request.new
    end

    def valid(request)
      request.merchant_txn_ref, request.order_info, request.amount, request.return_url =
        'merchant-txn-ref', 'order-info', 100, 'http://www.google.com'
      request
    end

    it 'should initialize with default attributes' do
      [:secret_code, :access_code, :merchant, :url].each do |attribute|
        @request.send(attribute).should_not be_blank
      end
    end

    it 'should initialize with options' do
      request = BankAudi::Request.new :merchant_txn_ref => 'merchant-txn-ref', :order_info => 'order-info',
        :amount => 100, :return_url => 'http://www.google.com'
      [:merchant_txn_ref, :order_info, :amount, :return_url].each do |attribute|
        request.send(attribute).should_not be_blank
      end
      request.should be_valid
    end

    it 'merchant_id is synonym of merchant' do
      @request.merchant_id.should eq(@request.merchant)
    end

    it 'should valid' do
      valid(@request).should be_valid
    end

    it 'should invalid' do
      @request.should_not be_valid
      [:merchant_txn_ref, :order_info, :amount, :return_url].each do |attribute|
        request = valid(@request)
        request.send("#{attribute}=", nil)
        request.should_not be_valid
      end
    end

    it 'should return full url' do
      url = valid(@request).full_url
      params = CGI::parse(url)
      params['vpc_SecureHash'].first.should eq('A37A981709D939C0E04B640E26677471')
    end

    it 'should return attributes (method attributes)' do
      default_attributes =  {
        :secret_code => 'XXXXXX', :access_code => 'XXXXXX', :merchant => 'XXXXXX',
        :url => 'https://gw1.audicards.com/TPGWeb/payment/prepayment.action'
      }

      @request.attributes.should eq(
        default_attributes.merge(:merchant_txn_ref => nil, :order_info => nil, :amount => nil,
          :return_url => nil)
      )

      valid(@request).attributes.should eq(
        default_attributes.merge(:merchant_txn_ref => 'merchant-txn-ref', :order_info => 'order-info',
          :amount => 100, :return_url => 'http://www.google.com')
      )
    end

    it 'should set attirubtes (method attributes=)' do
      @request.attributes = { :merchant_txn_ref => 'merchant-txn-ref', :order_info => 'order-info',
        :amount => 100, :return_url => 'http://www.google.com' }
      @request.attributes.should eq(
          valid(@request).attributes
      )
    end
  end
end
