module Net
  class LDAP
    class Connection
      def initialize(server)
        begin
          if ENV['LDAP_PROXY'].nil?
            @conn = TCPSocket.new(server[:host], server[:port])
          else
            socks = URI.parse(ENV['LDAP_PROXY'].to_s)
            TCPSOCKSSocket.socks_server = socks.host
            TCPSOCKSSocket.socks_port = socks.port
            TCPSOCKSSocket.socks_username = socks.user
            TCPSOCKSSocket.socks_password = socks.password
            @conn = TCPSOCKSSocket.new(server[:host], server[:port])
          end
        rescue SocketError
          raise Net::LDAP::LdapError, 'No such address or other socket error.'
        rescue Errno::ECONNREFUSED
          raise Net::LDAP::LdapError, "Server #{server[:host]} refused connection on port #{server[:port]}."
        end

        setup_encryption server[:encryption] if server[:encryption]

        yield self if block_given?
      end
    end
  end
end
