import { Request, Response } from "express";
import { generateProductId } from "./utils";
import * as dotenv from "dotenv";

dotenv.config();

interface Product {
  product_id: string;
  name: string;
  manufacturer: string;
  manufactureDate: string;
  expiryDate: string;
}

const ADDRES_REGEX: RegExp = /^0x[0-9a-fA-F]{64}$/;
const MAX_LENGTH: number = 10000;
const PINATA_JWT: string = process.env.PINATA_JWT || "";

const pinToIPFS = async (product: Product) => {
  const url = "https://api.pinata.cloud/pinning/pinFileToIPFS";

  const blob = new Blob([JSON.stringify(product, null, 2)], {
    type: "application/json"
  });

  const file = new File([blob], `${product.product_id}.txt`);
  const data = new FormData();
  data.append("file", file);

  const response = await fetch(url, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${PINATA_JWT}`
    },
    body: data
  });

  return await response.json();
};

export const submitProduct = async (req: Request, res: Response) => {
  const { name, manufacturer, manufactureDate, expiryDate } = req.body;

  if (!name || !manufacturer || !manufactureDate || !expiryDate) {
    return res.status(400).json({ error: "Missing text or address" });
  }

  const product_id = generateProductId(10);

  const productData: Product = {
    product_id,
    name,
    manufacturer,
    manufactureDate,
    expiryDate
  };

  try {
    const pin = await pinToIPFS(productData);

    return res.json({ ipfs_hash: pin.IpfsHash });
  } catch (error) {
    return res.status(500).json({ error: "Error uploading to IPFS" });
  }
};
