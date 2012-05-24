require "bank_audi/version"
require 'active_support/all'
require 'yaml'
require 'cgi'

module BankAudi
  OPTIONS = YAML.load_file('config/bank_audi.yml')

  class Request
    attr_reader :secret_code, :access_code, :merchant, :url
    attr_accessor :merchant_txn_ref, :order_info, :amount, :return_url
    alias :merchant_id :merchant

    def initialize(options = {})
      @secret_code, @access_code, @merchant, @url =
        OPTIONS['secret_code'], OPTIONS['access_code'], OPTIONS['merchant'], OPTIONS['url']
      @merchant_txn_ref, @order_info, @amount, @return_url =
        options[:merchant_txn_ref], options[:order_info], options[:amount], options[:return_url]
    end

    def valid?
      attributes_names.each do |attribute|
        return false if self.send(attribute).blank?
      end
    end

    def invalid?
      !valid?
    end

    def full_url
      return nil if invalid?
      params = String.new
      { 'accessCode' => @access_code, 'merchTxnRef' => @merchant_txn_ref, 'merchant' => @merchant,
        'orderInfo' => @order_info, 'amount' => @amount, 'returnURL' => @return_url }.each do |name, value|
          params << '&' if params.present?
          params << (CGI::escape(name) + '=' + CGI::escape(value.to_s))
        end
      params << '&vpc_SecureHash=' + vpc_secure_hash.to_s
      @url + '?' + params
    end

    def attributes
      value = {}
      attributes_names.each do |attribute|
        value[attribute.to_sym] = self.send(attribute)
      end
      value
    end

    def attributes=(value = {})
      value.each do |name, attr_value|
        self.send("#{name}=", attr_value)
      end
    end

    private
      def attributes_names
        %w(secret_code access_code merchant url merchant_txn_ref order_info amount return_url)
      end

      def vpc_secure_hash
        Digest::MD5.hexdigest(@secret_code.to_s + @access_code.to_s + @amount.to_s + @merchant_txn_ref.to_s +
          @merchant.to_s + @order_info.to_s + @return_url.to_s).upcase
      end
  end

  class Responce
  end
end
