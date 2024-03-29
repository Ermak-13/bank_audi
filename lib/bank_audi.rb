require "bank_audi/version"
require 'active_support/all'
require 'yaml'
require 'cgi'

module BankAudi
  OPTIONS = YAML.load_file('config/bank_audi.yml')

  class Request
    attr_reader :secret_code, :access_code, :merchant, :url, :errors
    attr_accessor :merchant_txn_ref, :order_info, :amount, :return_url
    alias :merchant_id :merchant

    def initialize(options = {})
      @secret_code, @access_code, @merchant, @url =
        OPTIONS['secret_code'], OPTIONS['access_code'], OPTIONS['merchant'], OPTIONS['url']
      @merchant_txn_ref, @order_info, @amount, @return_url =
        options[:merchant_txn_ref], options[:order_info], options[:amount], options[:return_url]
    end

    def valid?
      @errors = {}
      attributes_names.each do |attribute|
        if self.send(attribute).blank?
          @errors[attribute] = "can't be blank"
          return false
        end
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

  class Response
    attr_reader :secret_code, :errors
    attr_accessor :attributes

    def initialize(options = {})
      @secret_code, @attributes = OPTIONS['secret_code'], HashWithIndifferentAccess.new(options)
    end

    def attributes=(options = {})
      @attributes = HashWithIndifferentAccess.new(options)
    end

    def valid?
      @errors = {}
      valid_vpc_txn_response_code? && valid_vpc_secure_hash?
    end

    def vpc_secure_hash
      (@attributes[:vpc_secure_hash] || @attributes[:vpc_SecureHash]).upcase
    end

    def vpc_txn_response_code
      @attributes[:vpc_txn_response_code] || @attributes[:vpc_TxnResponseCode]
    end

    private
      def valid_vpc_secure_hash?
        params = @attributes.select { |k,v| !%w(vpc_secure_hash vpc_SecureHash).include?(k.to_s) }
        vpc_secure_hash_params = @secret_code
        sort_keys(params.keys).each do |key|
          vpc_secure_hash_params += @attributes[key].to_s
        end
        if Digest::MD5.hexdigest(vpc_secure_hash_params).upcase == vpc_secure_hash
          true
        else
          @errors[:vpc_secure_hash] = 'invalid'
          false
        end
      end

      def valid_vpc_txn_response_code?
        if vpc_txn_response_code == '0'
          true
        else
          @errors[:vpc_txn_response_code] = "bad code =  #{vpc_txn_response_code}"
          false
        end
      end

      def sort_keys(keys)
        keys.sort do |a,b|
          size = [a.length, b.length].min
          compare = 0
          size.times do |i|
            compare = (a[i] <=> b[i])
            break if compare != 0
          end
          if compare != 0
            compare
          else
            (a.length < b.length) ? 1 : -1
          end
        end
      end
  end
end
