vrrp_instance VI_1 {
	state __KA_STATE__
	interface __KA_IF__
	virtual_router_id 51
	priority __KA_PRIORITY__
	advert_int 1

	virtual_ipaddress {
		192.168.122.100/24
	}

	track_script {
		chk_haproxy
	}
}

vrrp_script chk_haproxy {
	script "curl -sf http://127.0.0.1/health"
	interval 2
	weight -20
}
