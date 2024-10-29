import { Injectable } from '@nestjs/common';
import { ProductDto } from './product.dto';
import { generateProductId } from '../utils';

@Injectable()
export class ProductsService {
    private readonly PINATA_JWT = process.env.PINATA_JWT || '';

    async pinToIPFS(product: any): Promise<any> {
        const url = 'https://api.pinata.cloud/pinning/pinFileToIPFS';

        const blob = new Blob([JSON.stringify(product, null, 2)], {
        type: 'application/json',
        });

        const file = new File([blob], `${product.product_id}.txt`);
        const data = new FormData();
        data.append('file', file);

        const response = await fetch(url, {
        method: 'POST',
        headers: {
            Authorization: `Bearer ${this.PINATA_JWT}`,
        },
        body: data,
        });

        console.log("Response: ", await response);

        if (!response.ok) {
            const errorBody = await response.json();
            console.error("Error Response:", errorBody);
            throw new Error(`Failed to upload to IPFS: ${errorBody.message || response.statusText}`);
        }

        return await response.json();
    }

    async submitProduct(createProductDto: ProductDto): Promise<string> {
        const product_id = generateProductId(10);
        const productData = { product_id, ...createProductDto };
    
        try {
            const pin = await this.pinToIPFS(productData);
            return pin.IpfsHash;
        } catch (error) {
            throw new Error('Error uploading to IPFS');
        }
    }
}
