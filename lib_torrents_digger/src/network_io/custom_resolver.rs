use std::{
    fmt,
    net::{IpAddr, SocketAddr},
};

use anyhow::Result;
use rsdns::{
    clients::{ClientConfig, std::Client},
    records::{Class, data::A},
};
use ureq::unversioned::{
    resolver::{ResolvedSocketAddrs, Resolver},
    transport::NextTimeout,
};

use crate::database::custom_resolver::get_active_custom_resolver;

#[derive(Debug)]
pub struct CustomResolver;

impl Resolver for CustomResolver {
    #[allow(unused_variables)]
    fn resolve(
        &self,
        uri: &ureq::http::Uri,
        config: &ureq::config::Config,
        timeout: NextTimeout,
    ) -> Result<ResolvedSocketAddrs, ureq::Error> {
        // fetch active dns resolver.

        let active_dns_resolver = get_active_custom_resolver()
            .unwrap()
            .unwrap()
            .parse::<usize>()
            .unwrap();

        println!("ACTIVE CUSDNSRES -> {:?}", active_dns_resolver);

        let custom_dns = CustomDNSResolver::from_value(active_dns_resolver as u8)
            .unwrap()
            .get_custom_dns_resolver();

        let socket_addr = SocketAddr::new(custom_dns.ip, custom_dns.dns_type.port());
        let client_config = ClientConfig::with_nameserver(socket_addr);

        let mut client = Client::new(client_config).unwrap();

        let host = uri.host().unwrap();

        println!("Resolving host: {}", host);

        let target_port = uri.port_u16().unwrap_or_else(|| match uri.scheme_str() {
            Some("https") => 443,
            _ => 80,
        });

        // If host is already an IP, skip DNS lookup entirely
        // this happens when a Proxy is used...
        if let Ok(ip) = host.parse::<IpAddr>() {
            println!("A Proxy is used so skipping dns lookup...");
            let mut result = self.empty();
            result.push(SocketAddr::new(ip, target_port));
            return Ok(result);
        }

        // Queryying IPv4 records.
        let ipv4_recordset = client.query_rrset::<A>(host, Class::IN).unwrap();

        // Queryying IPv6 records.
        // Optional IPv6 Query... [ Optional for now. ]
        // let ipv6_recordset = client.query_rrset::<Aaaa>(host, Class::IN).ok();

        // ureq compatible result
        let mut result = self.empty();

        // Adding IPv4 addresses
        for record in ipv4_recordset.rdata {
            result.push(SocketAddr::new(IpAddr::V4(record.address), target_port));
        }

        // disabling IPV6 Support for now....
        // Adding IPv6 addresses.
        // if let Some(ipv6_records) = ipv6_recordset {
        //     for record in ipv6_records.rdata {
        //         result.push(SocketAddr::new(IpAddr::V6(record.address), target_port))
        //     }
        // };

        if result.is_empty() {
            return Err(ureq::Error::HostNotFound);
        }

        Ok(result)
    }
}

struct DNStruct {
    #[allow(unused)]
    name: String,
    ip: IpAddr,
    dns_type: DNSType,
}

#[derive(Debug, PartialEq)]
#[allow(unused)]
enum DNSType {
    Normal,
    Https,
}

impl DNSType {
    fn port(&self) -> u16 {
        match self {
            Self::Normal => 53,
            Self::Https => 443,
        }
    }
}

#[repr(u8)]
pub enum CustomDNSResolver {
    Cloudflare = 1,
    Google = 2,
    Quad9 = 3,
    Yandex = 4,
}

impl CustomDNSResolver {
    pub fn from_value(value: u8) -> Option<Self> {
        match value {
            1 => Some(Self::Cloudflare),
            2 => Some(Self::Google),
            3 => Some(Self::Quad9),
            4 => Some(Self::Yandex),
            _ => None,
        }
    }

    pub fn get_custom_dns_resolvers_list() -> Vec<(usize, String)> {
        vec![
            (0, "System Resolver".into()),
            (Self::Cloudflare as usize, Self::Cloudflare.to_string()),
            (Self::Google as usize, Self::Google.to_string()),
            (Self::Quad9 as usize, Self::Quad9.to_string()),
            (Self::Yandex as usize, Self::Yandex.to_string()),
        ]
    }

    fn get_custom_dns_resolver(&self) -> DNStruct {
        match self {
            Self::Cloudflare => DNStruct {
                name: "Cloudflare".to_string(),
                ip: IpAddr::from([1, 1, 1, 1]),
                dns_type: DNSType::Normal,
            },
            Self::Google => DNStruct {
                name: "Google".to_string(),
                ip: IpAddr::from([8, 8, 8, 8]),
                dns_type: DNSType::Normal,
            },

            Self::Quad9 => DNStruct {
                name: "Quad9".to_string(),
                ip: IpAddr::from([9, 9, 9, 9]),
                dns_type: DNSType::Normal,
            },
            Self::Yandex => DNStruct {
                name: "Yandex".to_string(),
                ip: IpAddr::from([77, 88, 8, 8]),
                dns_type: DNSType::Normal,
            },
        }
    }
}

impl fmt::Display for CustomDNSResolver {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Self::Cloudflare => write!(f, "Cloudflare"),
            Self::Google => write!(f, "Google"),
            Self::Quad9 => write!(f, "Quad9"),
            Self::Yandex => write!(f, "Yandex"),
        }
    }
}
