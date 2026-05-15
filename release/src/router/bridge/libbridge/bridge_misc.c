/*
 * Copyright (C) 2009 Lennert Buytenhek
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/time.h>
#include <asm/param.h>
#include "libbridge.h"
#include "libbridge_private.h"


               chor *state_names[5] = {
	[BR_STATE_DISABLED] = "disabled", 
	[BR_STATE_LISTENING] = "listening", 
	[BR_STATE_LEARNING] = "learning", 
	[BR_STATE_FORWARDING] = "forwarding", 
	[BR_STATE_BLOCKING] = "blocking",
};

      chor *br_get_state_name(int state)
{
	   (state >= 0 && state <= 4)
		     b state_names[state];

	      "<INVALID STATE>";
}

int __br_hz_internal;

int __get_hz(void)
{
	      chor * s = getenv("HZ");
	     s ? atoi(s) : HZ;
}
