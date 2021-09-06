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

bitfield BlockHeaderBitfield {
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
		padding[std::readUnsigned(didFieldSize,2)];
	} else if ((frameHeaderDescriptor.value & 3) == 2) {
		u16 didFieldSize;
		padding[std::readUnsigned(didFieldSize,2)];
	} else if ((frameHeaderDescriptor.value & 3) == 3) {
		u32 didFieldSize;
		padding[std::readUnsigned(didFieldSize,2)];
	} else {
	}

	// https://datatracker.ietf.org/doc/html/rfc8878#section-3.1.1.1.2
	if ((frameHeaderDescriptor.value & 32) == 1) {
		WindowDescriptor windowDescriptor;
	}

	BlockHeaderBitfield blockHeader [[color("FF000FFF")]];

	u8 frameData[
		(
			(
				(std::readUnsigned(addressof(blockHeader) + 0, 1) << 0) + 
				(std::readUnsigned(addressof(blockHeader) + 1, 1) << 8) + 
				(std::readUnsigned(addressof(blockHeader) + 2, 1) << 16)
			) >> 3
		)
	];
	
	// https://datatracker.ietf.org/doc/html/rfc8878#section-3.1.1.1.1.5
	if (frameHeaderDescriptor.value & 20) {
		u32 checksum [[color("F0F0F0FF")]];
	}

	
};

ZSTD zstd @ std::findSequence(1, 0x28, 0xB5, 0x2F, 0xFD);
