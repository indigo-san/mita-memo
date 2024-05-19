import createMetadata from '@/utils/createMetadata';
import { PropsWithChildren } from 'react';

export const metadata = createMetadata('サインイン - Mita-memo', '/login');

export default async function Layout({ children }: PropsWithChildren) {
  return <>{children}</>;
}
