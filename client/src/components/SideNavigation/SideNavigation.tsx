import * as NavigationMenu from "@radix-ui/react-navigation-menu";
import type { ReactNode } from "react";
import { useState } from "react";
import { Link, LinkProps, useLocation } from "react-router-dom";

import styles from "./SideNavigation.module.css";
import { ArrowLeftOnRectangleIcon, ArrowRightOnRectangleIcon } from "@heroicons/react/24/outline";
import clsx from "clsx";

interface SideNavigationProps {
  expand: "left" | "right";
  children: ReactNode[];
}

const SideNavigation = ({ expand, children = [] }: SideNavigationProps) => {
  const [expanded, setExpanded] = useState(false);

  return (
    <NavigationMenu.Root
      className={styles.root}
      orientation="vertical"
      data-hover-expand={true}
      data-expanded={expanded}
    >
      <div className={styles.wrapper} data-expand={expand}>
        <div className={styles.list}>
          {children.map((child, index) => (
            <NavigationMenu.Item key={index} asChild>
              {child}
            </NavigationMenu.Item>
          ))}
        </div>
        <NavigationMenu.Item asChild>
          <button
            className={styles.collapse}
            onClick={() => setExpanded((prev) => !prev)}
            type="button"
          >
            {expanded ? (
              <ArrowLeftOnRectangleIcon width="24px" />
            ) : (
              <ArrowRightOnRectangleIcon width="24px" />
            )}
            <span>{expanded ? "Collapse" : "Expand"}</span>
          </button>
        </NavigationMenu.Item>
      </div>
    </NavigationMenu.Root>
  );
};

export const SideNavigationLink = ({ to, children }: LinkProps) => {
  const location = useLocation();
  const isActive = location?.pathname === to;

  return (
    <NavigationMenu.Link active={isActive} asChild>
      <Link className={clsx(styles.listItem, isActive && styles.active)} to={to}>
        {children}
      </Link>
    </NavigationMenu.Link>
  );
};

export default SideNavigation;