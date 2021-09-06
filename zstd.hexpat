#pragma MIME application/zstd

struct Header {
	u32 Magic;
};

bitfield FrameHeaderDescriptorBitfield {
	dictonary_id_flag : 2;
	content_checksum_flag : 1;
	reserved : 1;
	unused : 1;
	single_segment_flag : 1;
	frame_content_size_flag : 2;
};

union FrameHeaderDescriptor {
	u8 value;
	FrameHeaderDescriptorBitfield bits;
};

bitfield WindowDescriptorBitfield {
	mantissa : 3;
	exponent : 5;
};

union WindowDescriptor {
	u8 value;
	WindowDescriptorBitfield bits;
};

bitfield BlockBitfield {
	last_block : 1;
	block_type : 2;
	block_size : 21;
};

struct ZSTD {
	u32 zstdHeader;

	// https://datatracker.ietf.org/doc/html/rfc8878#section-3.1.1.1.1
	FrameHeaderDescriptor frameHeaderDescriptor;
	
	// https://datatracker.ietf.org/doc/html/rfc8878#section-3.1.1.1.1.1
	if ((frameHeaderDescriptor.value >> 6) == 3) {
		u64 fcsFieldSize;
	} else if ((frameHeaderDescriptor.value >> 6) == 2) {
		u32 fcsFieldSize;
	} else if ((frameHeaderDescriptor.value >> 6) == 1) {
		u16 fcsFieldSize;
	} else {
		if ((frameHeaderDescriptor.value & 32) == 1) {
			u8 fcsFieldSize;
		}
	}

	// https://datatracker.ietf.org/doc/html/rfc8878#section-3.1.1.1.1.6
	if ((frameHeaderDescriptor.value & 3) == 1) {
		u8 didFieldSize;
		padding[readUnsigned(didFieldSize)];
	} else if ((frameHeaderDescriptor.value & 3) == 2) {
		u16 didFieldSize;
		padding[readUnsigned(didFieldSize)];
	} else if ((frameHeaderDescriptor.value & 3) == 3) {
		u32 didFieldSize;
		padding[readUnsigned(didFieldSize)];
	} else {
	}

	// https://datatracker.ietf.org/doc/html/rfc8878#section-3.1.1.1.2
	if ((frameHeaderDescriptor.value & 32) == 1) {
		WindowDescriptor windowDescriptor;
	}

	BlockBitfield block;
	padding[
		(
			(
				(readUnsigned(addressof(block) + 0, 2) << 0x0) + 
				(readUnsigned(addressof(block) + 1, 2) << 0x08) + 
				(readUnsigned(addressof(block) + 2, 2) << 0x10)
			) >> 3
		)
	];

	u32 comment;
	
};

ZSTD zstd @ $;
