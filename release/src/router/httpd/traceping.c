/*
 *
 * Tomato Firmware
 * Copyright (C) 2006-2009 Jonathan Zarate
 *
 * Fixes/updates (C) 2018 - 2026 pedro
 * https://freshtomato.org/
 *
 */
#include "tomato.h"
#include <ctype.h>

/* Validate a hostname or IP address for use in shell commands.
 * Allows alphanumeric, dot, hyphen, colon (IPv6), underscore (valid in hostnames).
 * Returns 1 if valid, 0 if not. */
static int check_addr(const char *addr, int max)
{
	const char *p;
	char c;

	if ((addr == NULL) || (addr[0] == 0))
		return 0;

	p = addr;
	while (*p) {
		c = *p;
		if ((!isalnum(c)) && (c != '.') && (c != '-') && (c != ':') && (c != '_'))
			return 0;
		++p;
	}
	return ((p - addr) <= max);
}

/* Clamp an integer value to [min, max] range.
 * Used to sanitize user-supplied numeric parameters before passing to shell. */
static int clamp_int(int val, int min, int max)
{
	if (val < min) return min;
	if (val > max) return max;
	return val;
}

void wo_trace(char *url)
{
	char cmd[256];
	const char *addr;
	int hops, wait;

	addr = webcgi_get("addr");
	if (!check_addr(addr, 64))
		return;

	/* clamp hops to [1, 30] and wait to [1, 10] seconds */
	hops = clamp_int(atoi(webcgi_safeget("hops", "1")), 1, 30);
	wait = clamp_int(atoi(webcgi_safeget("wait", "1")), 1, 10);

	killall("traceroute", SIGTERM);
	web_puts("\ntracedata = '");
	snprintf(cmd, sizeof(cmd), "traceroute -I -m %d -w %d %s", hops, wait, addr);
	web_pipecmd(cmd, WOF_JAVASCRIPT);
	web_puts("';");
}

void wo_ping(char *url)
{
	char cmd[256];
	const char *addr;
	int count, size;

	addr = webcgi_get("addr");
	if (!check_addr(addr, 64))
		return;

	/* clamp count to [1, 50] and size to [1, 1472] bytes (max non-fragmented) */
	count = clamp_int(atoi(webcgi_safeget("count", "1")), 1, 50);
	size  = clamp_int(atoi(webcgi_safeget("size",  "56")), 1, 1472);

	killall("ping", SIGTERM);
	web_puts("\npingdata = '");
	snprintf(cmd, sizeof(cmd), "ping -c %d -s %d %s", count, size, addr);
	web_pipecmd(cmd, WOF_JAVASCRIPT);
	web_puts("';");
}
