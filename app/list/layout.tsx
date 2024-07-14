import createMetadata from '@/utils/createMetadata';
import type { PropsWithChildren } from 'react';

export const metadata = createMetadata('リスト - Mita-memo', '/list');

export default async function Layout({ children }: PropsWithChildren) {
  return <>{children}</>;
}
